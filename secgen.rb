require 'getoptlong'
require 'fileutils'

require_relative 'lib/helpers/constants.rb'
require_relative 'lib/helpers/print.rb'
require_relative 'lib/helpers/gem_exec.rb'
require_relative 'lib/readers/system_reader.rb'
require_relative 'lib/readers/module_reader.rb'
require_relative 'lib/output/project_files_creator.rb'

# Displays secgen usage data
def usage
  Print.std "Usage:
   #{$0} [--options] <command>

   OPTIONS:
   --scenario [xml file], -s [xml file]: set the scenario to use
              (defaults to #{SCENARIO_XML})
   --project [output dir], -p [output dir]: directory for the generated project
              (output will default to #{default_project_dir})
   --help, -h: shows this usage information

   COMMANDS:
   run, r: builds project and then builds the VMs
   build-project, p: builds project (vagrant and puppet config), but does not build VMs
   build-vms [/project/dir], v [project #]: builds VMs from a previously generated project
              (use in combination with --project [dir])
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

  Print.info 'Reading available base modules...'
  all_available_bases = ModuleReader.read_bases
  Print.std "#{all_available_bases.size} base modules loaded"

  Print.info 'Reading available vulnerability modules...'
  all_available_vulnerabilties = ModuleReader.read_vulnerabilities
  Print.std "#{all_available_vulnerabilties.size} vulnerability modules loaded"

  Print.info 'Reading available service modules...'
  all_available_services = ModuleReader.read_services
  Print.std "#{all_available_services.size} service modules loaded"

  Print.info 'Reading available utility modules...'
  all_available_utilities = ModuleReader.read_utilities
  Print.std "#{all_available_utilities.size} utility modules loaded"

  Print.info 'Reading available network modules...'
  all_available_networks = ModuleReader.read_networks
  Print.std "#{all_available_networks.size} network modules loaded"

  Print.info 'Resolving systems: randomising scenario...'
  # for each system, select modules
  all_available_modules = all_available_bases + all_available_vulnerabilties + all_available_services + all_available_utilities + all_available_networks
  # update systems with module selections
  systems.map! {|system|
    system.module_selections = system.resolve_module_selection(all_available_modules)
    system
  }

  Print.info "Creating project: #{out_dir}..."
  # create's vagrant file / report a starts the vagrant installation'
  creator = ProjectFilesCreator.new(systems, out_dir, scenario, options)
  creator.write_files

  Print.info 'Project files created.'
end

# Builds the vm via the vagrant file in the project dir
# @param project_dir
def build_vms(project_dir)
  Print.info "Building project: #{project_dir}"
  GemExec.exe('vagrant', project_dir, 'up')
  Print.info 'VMs created.'
end

# Runs methods to run and configure a new vm from the configuration file
def run(scenario, project_dir, options)
  build_config(scenario, project_dir, options)
  build_vms(project_dir)
end

def default_project_dir
  "#{PROJECTS_DIR}/SecGen#{Time.new.strftime("%Y%m%d_%H%M")}"
end

# end of method declarations
# start of program execution

Print.std '~'*47
Print.std 'SecGen - Creates virtualised security scenarios'
Print.std '            Licensed GPLv3 2014-16'
Print.std '~'*47

# Get command line arguments
opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--project', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--scenario', '-s', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--gui-output', '-g', GetoptLong::NO_ARGUMENT],
  [ '--memory-per-vm', GetoptLong::REQUIRED_ARGUMENT],
  [ '--total-memory', GetoptLong::REQUIRED_ARGUMENT],
  [ '--max-cpu-cores', GetoptLong::REQUIRED_ARGUMENT],
  [ '--max-cpu-usage', GetoptLong::REQUIRED_ARGUMENT],
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

    # Additional options
    when '--gui-output'
      Print.info "Gui output set (virtual machines will be spawned)"
      options[:gui_output] = true

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

    when '--max-cpu-cores'
      Print.info "Number of cpus to be used set to #{arg}"
      options[:max_cpu_cores] = arg

    when '--max-cpu-usage'
      Print.info "Max CPU usage set to #{arg}"
      options[:max_cpu_usage] = arg

    else
      Print.err "Argument not valid: #{arg}"
      usage
      exit
  end
end

# at least one command
if ARGV.length < 1
  Print.err 'Missing command'
  usage
  exit
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
      build_vms(project_dir)
    else
      Print.err 'Please specify project directory to read'
      usage
      exit
    end
  else
    Print.err "Command not valid: #{ARGV[0]}"
    usage
    exit
end

