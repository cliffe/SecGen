require 'getoptlong'
require 'fileutils'
require 'nori'

require_relative 'lib/helpers/constants.rb'
require_relative 'lib/helpers/print.rb'
require_relative 'lib/helpers/gem_exec.rb'
require_relative 'lib/helpers/ovirt.rb'
require_relative 'lib/readers/system_reader.rb'
require_relative 'lib/readers/module_reader.rb'
require_relative 'lib/output/project_files_creator.rb'

# Displays secgen usage data
def usage
  Print.std "Usage:
   #{$0} [--options] <command>

   OPTIONS:
   --scenario [xml file], -s [xml file]: Set the scenario to use
              (defaults to #{SCENARIO_XML})
   --project [output dir], -p [output dir]: Directory for the generated project
              (output will default to #{default_project_dir})
   --shutdown: Shutdown VMs after provisioning (vagrant halt)
   --network-ranges: Override network ranges within the scenario, use a comma-separated list
   --forensic-image-type [image type]: Forensic image format of generated image (raw, ewf)
   --read-options [conf path]: Reads options stored in file as arguments (see example.conf)
   --memory-per-vm: Allocate generated VMs memory in MB (e.g. --memory-per-vm 1024)
   --total-memory: Allocate total VM memory for the scenario, split evenly across all VMs.
   --cpu-cores: Number of virtual CPUs for generated VMs
   --help, -h: Shows this usage information
   --system, -y [system_name]: Only build this system_name from the scenario
   --snapshot: Creates a snapshot of VMs once built

   VIRTUALBOX OPTIONS:
   --gui-output, -g: Show the running VM (not headless)
   --nopae: Disable PAE support
   --hwvirtex: Enable HW virtex support
   --vtxvpid: Enable VTX support
   --max-cpu-usage [1-100]: Controls how much cpu time a virtual CPU can use
                            (e.g. 50 implies a single virtual CPU can use up to 50% of a single host CPU)

   OVIRT OPTIONS:
   --ovirtuser [ovirt_username]
   --ovirtpass [ovirt_password]
   --ovirt-url [ovirt_api_url]
   --ovirtauthz [ovirt authz]
   --ovirt-cluster [ovirt_cluster]
   --ovirt-network [ovirt_network_name]
   --ovirt-affinity-group [ovirt_affinity_group_name]

   ESXI OPTIONS:
   --esxiuser [esxi_username]
   --esxipass [esxi_password]
   --esxi-url [esxi_api_url]
   --esxi-datastore [esxi_datastore]
   --esxi-disktype [esxi_disktype]
   --esxi-network [esxi_network_name]

   COMMANDS:
   run, r: Builds project and then builds the VMs
   build-project, p: Builds project (vagrant and puppet config), but does not build VMs
   build-vms, v: Builds VMs from a previously generated project
              (use in combination with --project [dir])
   ovirt-post-build: only performs the ovirt actions that normally follow a successful vm build
              (snapshots and networking)
   create-forensic-image: Builds forensic images from a previously generated project
              (can be used in combination with --project [dir])
   list-scenarios: Lists all scenarios that can be used with the --scenario option
   list-projects: Lists all projects that can be used with the --project option
   delete-all-projects: Deletes all current projects in the projects directory
"
  exit
end

# Builds the vagrant configuration file based on a scenario file
# @return build_number [Integer] Current project's build number
def build_config(scenario, out_dir, options)
  Print.info 'Reading configuration file for virtual machines you want to create...'
  # read the scenario file describing the systems, which contain vulnerabilities, services, etc
  # this returns an array/hashes structure
  systems = SystemReader.read_scenario(scenario)
  Print.std "#{systems.size} system(s) specified"

  all_available_modules = ModuleReader.get_all_available_modules

  Print.info 'Resolving systems: randomising scenario...'
  # update systems with module selections
  systems.map! { |system|
    system.module_selections = system.resolve_module_selection(all_available_modules, options)
    system
  }

  Print.info "Creating project: #{out_dir}..."
  # creates Vagrantfile and other outputs and starts the vagrant installation
  creator = ProjectFilesCreator.new(systems, out_dir, scenario, options)
  creator.write_files

  Print.info 'Project files created.'
end

# Builds the vm via the vagrant file in the project dir
# @param project_dir
def build_vms(scenario, project_dir, options)
  unless project_dir.include? ROOT_DIR
    Print.info 'Relative path to project detected'
    project_dir = "#{ROOT_DIR}/#{project_dir}"
    Print.info "Using #{project_dir}"
  end

  project_dir + '/scenario.xml'

  Print.info "Building project: #{project_dir}"
  system = ''
  command = 'up'
  if options.has_key? :system
    system = options[:system]
  end
  if options.has_key? :reload
    command = '--provision reload'
  end

  # if deploying to ovirt, when things fail to build, set the retry_count
  retry_count = OVirtFunctions::provider_ovirt?(options) ? 2 : 0
  successful_creation = false

  while retry_count and !successful_creation
    vagrant_output = GemExec.exe('vagrant', project_dir, "#{command} #{system}")
    if vagrant_output[:status] == 0
      Print.info 'VMs created.'
      successful_creation = true
      if options[:shutdown] or OVirtFunctions::provider_ovirt?(options)
        Print.info 'Shutting down VMs.'
        sleep(30)
        GemExec.exe('vagrant', project_dir, 'halt')
      end
    else
      if retry_count > 0
        # Identify which VMs failed
        if vagrant_output[:exception].class == ProcessHelper::UnexpectedExitStatusError
          split = vagrant_output[:output].split('==> ')
          failures_to_destroy = []
          split.each do |line|
            if match = line.match(/^([-a-zA-Z_0-9]+):[^:]+An error occured/i)
              vm_to_destroy = match.captures[0]
              failures_to_destroy << vm_to_destroy
            elsif match = line.match(/^([-a-zA-Z_0-9]+):[^:]+Error:/i)
              vm_to_destroy = match.captures[0]
              failures_to_destroy << vm_to_destroy
            elsif match = line.match(/^([-a-zA-Z_0-9]+):[^:]+VM is not created/i)
              vm_not_to_destroy = match.captures[0]
              Print.err "Not going to destroy #{vm_not_to_destroy}, since it does not exist"
              failures_to_destroy.delete_if {|x| x == vm_not_to_destroy }
              # TODO: not sure if there is a need to remove_uncreated_vms() here too? (I don't think so?)
            end
          end

          failures_to_destroy = failures_to_destroy.uniq

          if failures_to_destroy.size == 0
            Print.err 'Failed. Not retrying. Please refer to the error above.'
            exit 1
          end
          Print.err 'Error creating VMs [' + failures_to_destroy.join(',') + '] destroying VMs and retrying...'
          failures_to_destroy.each do |failed_vm|
            destroy = 'destroy ' + failed_vm + ' -f'
            destroy_output = GemExec.exe('vagrant', project_dir, destroy)
            if destroy_output[:status] == 0
              if !destroy_output[:output].include? 'VM is not created. Please run `vagrant up` first.'
                Print.info "vagrant #{destroy} completed successfully."
              else
                OVirtFunctions::remove_uncreated_vms(destroy_output[:output], options, scenario)
                # Add ESXI destroy uncreated VMs
              end
            else
              Print.err "Failed to destroy #{failed_vm}. Exiting."
              exit 1
            end
            sleep(10)
          end
        else   # TODO:  elsif vagrant_output[:exception].type == ProcessHelper::TimeoutError   >destroy individually broken vms as above?
          Print.err 'Vagrant up timeout, destroying VMs and retrying...'
          GemExec.exe('vagrant', project_dir, 'destroy -f')
        end
      else
        Print.err 'Error provisioning VMs, destroying VMs and exiting SecGen.'
        GemExec.exe('vagrant', project_dir, 'destroy -f')
        exit 1
      end
    end
    retry_count -= 1
  end
  if successful_creation
    ovirt_post_build(options, scenario, project_dir) if OVirtFunctions.provider_ovirt?(options)
    if options[:snapshot]
      Print.info 'Creating a snapshot of VM(s)'
      sleep(20) # give oVirt/Virtualbox a chance to save any VM config changes before creating the snapshot
      if OVirtFunctions::provider_ovirt?(options)
        OVirtFunctions::create_snapshot(options, scenario, get_vm_names(scenario))
      else
        GemExec.exe('vagrant', project_dir, 'snapshot push')
      end
    end
  else
    Print.err "Failed to build VMs"
    exit 1
  end
end

# actions on the VMs after vagrant has built them
# this includes networking and snapshots
def ovirt_post_build(options, scenario, project_dir)
  Print.std 'Taking oVirt post-build actions...'
  if options[:ovirtnetwork]
    Print.info 'Assigning network(s) of VM(s)'
    OVirtFunctions::assign_networks(options, scenario, get_vm_names(scenario))
  end
  if options[:ovirtaffinitygroup]
    Print.info 'Assigning affinity group of VM(s)'
    OVirtFunctions::assign_affinity_group(options, scenario, get_vm_names(scenario))
  end
end

# Make forensic image helper methods
#################################################
# Create an EWF forensic image
#
# @author Jason Keighley
# @return [Void]
def create_ewf_image(drive_path, image_output_location)
  ## Make E01 image
  Print.info "Creating E01 image with path #{image_output_location}.E01"
  Print.info 'This may take a while:'
  Print.info "E01 image #{image_output_location}.E01 created" if system "ftkimager '#{drive_path}' '#{image_output_location}' --e01"
end

# Create an DD forensic image
#
# @author Jason Keighley
# @return [Void]
def create_dd_image(drive_path, image_output_location)
  ## Make DD image
  Print.info "Creating dd image with path #{image_output_location}.raw"
  Print.info 'This may take a while:'
  Print.info "Raw image #{image_output_location}.raw created" if system "VBoxManage clonemedium disk '#{drive_path}' '#{image_output_location}.raw' --format RAW"
end

# Delete virtualbox virtual machine
#
# @author Jason Keighley
# @param [String] vm_name Virtual machine name in VirtualBox
# @return [Void]
def delete_virtualbox_vm(vm_name)
  Print.info "Deleting VirtualBox VM #{vm_name}"
  Print.info "VirtualBox VM #{vm_name} deleted" if system "VBoxManage unregistervm #{vm_name} --delete"
end

# Make forensic image helper methods \end
#################################################

def make_forensic_image(project_dir, image_output_location, image_type)
  drive_path = %x(VBoxManage list hdds | grep '#{project_dir.split('/').last}').sub(/\ALocation:\s*/, '').sub(/\n/, '')
  drive_name = drive_path.split('/').last

  image_output_location = "#{project_dir}/#{drive_name}".sub(/.vmdk|.vdi/, '') unless image_output_location

  ## Ensure all vms are shutdown
  system "cd '#{project_dir}' && vagrant halt"

  case image_type.downcase
    when 'raw', 'dd'
      create_dd_image(drive_path, image_output_location)

    when 'ewf', 'e01'
      create_ewf_image(drive_path, image_output_location)

    else
      Print.info "The image type [#{image_type}] is not recognised."
  end

end

# Runs methods to run and configure a new vm from the configuration file
def run(scenario, project_dir, options)
  build_config(scenario, project_dir, options)
  build_vms(scenario, project_dir, options)
end

def default_project_dir
  "#{PROJECTS_DIR}/SecGen#{Time.new.strftime("%Y%m%d_%H%M%S")}"
end


def project_dir(prefix)
  "#{PROJECTS_DIR}/#{prefix}_SecGen#{Time.new.strftime("%Y%m%d_%H%M%S")}"
end

def list_scenarios
  Print.std "Full paths to scenario files are displayed below"
  Dir["#{ROOT_DIR}/scenarios/**/*"].select { |file| !File.directory? file }.each_with_index do |scenario_name, scenario_number|
    Print.std "#{scenario_number}) #{scenario_name}"
  end
end

def list_projects
  Print.std "Full paths to project directories are displayed below"
  Dir["#{PROJECTS_DIR}/*"].select { |file| !File.file? file }.each_with_index do |scenario_name, scenario_number|
    Print.std "#{scenario_number}) #{scenario_name}"
  end
end

# Delete all current project directories
#
# @author Jason Keighley
# @return [Void]
def delete_all_projects
  FileUtils.rm_r(Dir.glob("#{PROJECTS_DIR}/*"))
end

# returns an array containing the system names from the scenario
def get_vm_names(scenario)
  vm_names = []
  parser = Nori.new
  scenario_hash = parser.parse(File.read(scenario))
  Print.debug "scenario_hash: #{scenario_hash}"
  if scenario_hash.key?('scenario') # work around for a parsing quirk
    scenario_hash = scenario_hash['scenario']
  end
  if scenario_hash['system'].is_a? Array
    scenario_hash['system'].each do |system|
      vm_names << system['system_name']
    end
  elsif scenario_hash['system'].is_a? Hash
    vm_names << scenario_hash['system']['system_name']
  else
    Print.debug "Not an array or hash?: #{scenario_hash['system']}"
  end
  Print.debug vm_names.to_s
  vm_names
end

# end of method declarations
# start of program execution

Print.std '~'*47
Print.std 'SecGen - Creates virtualised security scenarios'
Print.std '            Licensed GPLv3 2014-18'
Print.std '~'*47
Print.debug "\nPlease take a minute to tell us how you are using SecGen:"
Print.debug "https://tinyurl.com/SecGenFeedback\n"

# Add read-options from config file (needs handling before options parsed by GetoptLong)
if ARGV.include? '--read-options'
  index = ARGV.find_index('--read-options')
  conf_path = ARGV[index + 1]

  # remove --read-options and conf_path
  ARGV.delete_at(index)
  ARGV.delete_at(index)

  conf_data = File.read(conf_path).split(' ')
  ARGV.unshift(*conf_data)
end

# Get command line arguments
opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--project', '-p', GetoptLong::REQUIRED_ARGUMENT],
    ['--scenario', '-s', GetoptLong::REQUIRED_ARGUMENT],
    ['--prefix', GetoptLong::REQUIRED_ARGUMENT],
    ['--system', '-y', GetoptLong::REQUIRED_ARGUMENT],
    ['--reload', '-r', GetoptLong::NO_ARGUMENT],
    ['--gui-output', '-g', GetoptLong::NO_ARGUMENT],
    ['--nopae', GetoptLong::NO_ARGUMENT],
    ['--hwvirtex', GetoptLong::NO_ARGUMENT],
    ['--vtxvpid', GetoptLong::NO_ARGUMENT],
    ['--memory-per-vm', GetoptLong::REQUIRED_ARGUMENT],
    ['--total-memory', GetoptLong::REQUIRED_ARGUMENT],
    ['--cpu-cores', GetoptLong::REQUIRED_ARGUMENT],
    ['--max-cpu-usage', GetoptLong::REQUIRED_ARGUMENT],
    ['--shutdown', GetoptLong::NO_ARGUMENT],
    ['--network-ranges', GetoptLong::REQUIRED_ARGUMENT],
    ['--forensic-image-type', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirtuser', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirtpass', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirt-url', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirtauthz', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirt-cluster', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirt-network', GetoptLong::REQUIRED_ARGUMENT],
    ['--ovirt-affinity-group', GetoptLong::REQUIRED_ARGUMENT],
    ['--snapshot', GetoptLong::NO_ARGUMENT],
    ['--esxiuser', GetoptLong::REQUIRED_ARGUMENT],
    ['--esxipass', GetoptLong::REQUIRED_ARGUMENT],
    ['--esxi-url', GetoptLong::REQUIRED_ARGUMENT],
    ['--esxi-datastore', GetoptLong::REQUIRED_ARGUMENT],
    ['--esxi-network', GetoptLong::REQUIRED_ARGUMENT],
)

scenario = SCENARIO_XML
project_dir = nil
options = {}

# process option arguments
opts.each do |opt, arg|
  case opt
    # Main options
    when '--help'
      usage
    when '--scenario'
      scenario = arg;
    when '--project'
      project_dir = arg;
    when '--prefix'
      options[:prefix] = arg
      project_dir = project_dir(arg)

    # Additional options
    when '--system'
      Print.info "VM control (Vagrant) commands will only apply to system #{arg} (must match a system defined in the scenario)"
      options[:system] = arg
    when '--reload'
      Print.info "Will reload and re-provision the VMs"
      options[:reload] = true
    when '--gui-output'
      Print.info "Gui output set (virtual machines will be spawned)"
      options[:gui_output] = true
    when '--nopae'
      Print.info "no pae"
      options[:nopae] = true
    when '--hwvirtex'
      Print.info "with HW virtualisation"
      options[:hwvirtex] = true
    when '--vtxvpid'
      Print.info "with VT support"
      options[:vtxvpid] = true
    when '--memory-per-vm'
      if options.has_key? :total_memory
        Print.info 'Total memory option specified before memory per vm option, defaulting to total memory value'
      else
        Print.info "Memory per vm set to #{arg}"
        options[:memory_per_vm] = arg
      end
    when '--total-memory'
      if options.has_key? :memory_per_vm
        Print.info 'Memory per vm option specified before total memory option, defaulting to memory per vm value'
      else
        Print.info "Total memory to be used set to #{arg}"
        options[:total_memory] = arg
      end
    when '--cpu-cores'
      Print.info "Number of cpus to be used set to #{arg}"
      options[:cpu_cores] = arg
    when '--max-cpu-usage'
      Print.info "Max CPU usage set to #{arg}"
      options[:max_cpu_usage] = arg
    when '--shutdown'
      Print.info 'Shutdown VMs after provisioning'
      options[:shutdown] = true
    when '--network-ranges'
      Print.info 'Overriding Network Ranges'
      options[:ip_ranges] = arg.split(',')
    when '--forensic-image-type'
      Print.info "Image output type set to #{arg}"
      options[:forensic_image_type] = arg

    when '--ovirtuser'
      Print.info "Ovirt Username : #{arg}"
      options[:ovirtuser] = arg
    when '--ovirtpass'
      Print.info "Ovirt Password : ********"
      options[:ovirtpass] = arg
    when '--ovirt-url'
      Print.info "Ovirt API url : #{arg}"
      options[:ovirturl] = arg
    when '--ovirtauthz'
      Print.info "Ovirt Authz: #{arg}"
      options[:ovirtauthz] = arg
    when '--ovirt-cluster'
      Print.info "Ovirt Cluster : #{arg}"
      options[:ovirtcluster] = arg
    when '--ovirt-network'
      Print.info "Ovirt Network Name : #{arg}"
      options[:ovirtnetwork] = arg
    when '--ovirt-affinity-group'
      Print.info "Ovirt Affinity Group : #{arg}"
      options[:ovirtaffinitygroup] = arg
    when '--snapshot'
      Print.info "Taking snapshots when VMs are created"
      options[:snapshot] = true

    when '--esxiuser'
      Print.info "ESXi Username : #{arg}"
      options[:esxiuser] = arg
    when '--esxipass'
      Print.info "ESXi Password : ********"
      options[:esxipass] = arg
    when '--esxi-url'
      Print.info "ESXi host url : #{arg}"
      options[:esxiurl] = arg
    when '--esxi-datastore'
      Print.info "ESXi datastore: #{arg}"
      options[:esxidatastore] = arg
    when '--esxi-network'
      Print.info "ESXi Network Name : #{arg}"
      options[:esxinetwork] = arg
    when '--esxi-disktype'
      Print.info "ESXi disk type : #{arg}"
      options[:esxidisktype] = arg
    when '--snapshot'
      Print.info "Taking snapshots when VMs are created"
      options[:snapshot] = true

    else
      Print.err "Argument not valid: #{arg}"
      usage
      exit 1
  end
end

# at least one command
if ARGV.length < 1
  Print.err 'Missing command'
  usage
  exit 1
end

# process command
case ARGV[0]
  when 'run', 'r'
    project_dir = default_project_dir unless project_dir
    run(scenario, project_dir, options)
  when 'build-project', 'p'
    project_dir = default_project_dir unless project_dir
    build_config(scenario, project_dir, options)
  when 'build-vms', 'v'
    if project_dir
      build_vms(scenario, project_dir, options)
    else
      Print.err 'Please specify project directory to read'
      usage
      exit 1
    end

  when 'create-forensic-image'
    image_type = options.has_key?(:forensic_image_type) ? options[:forensic_image_type] : 'raw';

    if project_dir
      build_vms(scenario, project_dir, options)
      make_forensic_image(project_dir, nil, image_type)
    else
      project_dir = default_project_dir unless project_dir
      build_config(scenario, project_dir, options)
      build_vms(scenario, project_dir, options)
      make_forensic_image(project_dir, nil, image_type)
    end

  when 'esxi-post-build'
    esxi_post_build(options, scenario, project_dir)
    exit 0

  when 'ovirt-post-build'
    ovirt_post_build(options, scenario, project_dir)
    exit 0

  when 'list-scenarios'
    list_scenarios
    exit 0

  when 'list-projects'
    list_projects
    exit 0

  when 'delete-all-projects'
    delete_all_projects
    Print.std 'All projects deleted'
    exit 0

  else
    Print.err "Command not valid: #{ARGV[0]}"
    usage
    exit 1
end
