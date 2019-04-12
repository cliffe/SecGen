require 'erb'
require_relative '../helpers/constants.rb'
require_relative 'xml_scenario_generator.rb'
require_relative 'xml_marker_generator.rb'
require_relative 'ctfd_generator.rb'
require 'fileutils'
require 'librarian'
require 'zip/zip'

class ProjectFilesCreator
# Creates project directory, uses .erb files to create a report and the vagrant file that will be used
# to create the virtual machines
  @systems
  @currently_processing_system
  @scenario_networks
  @option_range_map

# @param [Object] systems list of systems that have been defined and randomised
# @param [Object] out_dir the directory that the project output should be stored into
# @param [Object] scenario the file path used to as a basis
  def initialize(systems, out_dir, scenario, options)
    @systems = systems
    @out_dir = out_dir

    # if within the SecGen directory structure, trim that from the path displayed in output
    match = scenario.match(/#{ROOT_DIR}\/(.*)/i)
    if match && match.captures.size == 1
      scenario = match.captures[0]
    end
    @scenario = scenario
    @time = Time.new.to_s
    @options = options
    @scenario_networks = Hash.new { |h, k| h[k] = 1 }
    @option_range_map = {}
  end

# Generate all relevant files for the project
  def write_files
    # when writing to a project that already contains a project, move everything out the way,
    # and keep the Vagrant config, so that existing VMs can be re-provisioned/updated
    if File.exists? "#{@out_dir}/Vagrantfile" or File.exists? "#{@out_dir}/puppet"
      dest_dir = "#{@out_dir}/MOVED_#{Time.new.strftime("%Y%m%d_%H%M%S")}"
      Print.warn "Project already built to this directory -- moving last build to: #{dest_dir}"
      Dir.glob( "#{@out_dir}/**/*" ).select { |f| File.file?( f ) }.each do |f|
        dest = "#{dest_dir}/#{f}"
        FileUtils.mkdir_p( File.dirname( dest ) )
        if f =~ /\.vagrant/
          FileUtils.cp( f, dest )
        else
          FileUtils.mv( f, dest )
        end
      end
    end

    FileUtils.mkpath "#{@out_dir}" unless File.exists?("#{@out_dir}")
    FileUtils.mkpath "#{@out_dir}/puppet/" unless File.exists?("#{@out_dir}/puppet/")
    FileUtils.mkpath "#{@out_dir}/environments/production/" unless File.exists?("#{@out_dir}/environments/production/")

    # for each system, create a puppet modules directory using librarian-puppet
    @systems.each do |system|
      @currently_processing_system = system # for template access
      path = "#{@out_dir}/puppet/#{system.name}"
      FileUtils.mkpath(path) unless File.exists?(path)
      pfile = "#{path}/Puppetfile"
      Print.std "Creating Puppet modules librarian-puppet file: #{pfile}"
      template_based_file_write(PUPPET_TEMPLATE_FILE, pfile)
      Print.std 'Preparing puppet modules using librarian-puppet'
      librarian_output = GemExec.exe('librarian-puppet', path, 'install --verbose')
      if librarian_output[:status] != 0
        Print.err 'Failed to prepare puppet modules!'
        abort
      end
      system.module_selections.each do |selected_module|

        if selected_module.module_type == 'base'
          url = selected_module.attributes['url'].first

          unless url.nil? || url =~ /^http*/
            Print.std "Checking to see if local basebox #{url.split('/').last} exists"
            packerfile_path = "#{BASES_DIR}#{selected_module.attributes['packerfile_path'].first}"
            autounattend_path = "#{BASES_DIR}#{selected_module.attributes['packerfile_path'].first.split('/').first}/Autounattend.xml.erb"

            unless File.file? "#{VAGRANT_BASEBOX_STORAGE}/#{url}"
              Print.std "Basebox #{url.split('/').last} not found, searching for packerfile"

              if File.file? packerfile_path
                Print.info "Would you like to use the packerfile to create the packerfile from the given url (y/n)"
                # TODO: remove user interaction, this should be set via a config option
                (Print.info "Exiting as vagrant needs the basebox to continue"; abort) unless ['y','yes'].include?(STDIN.gets.chomp.downcase)

                Print.std "Packerfile #{packerfile_path.split('/').last} found, building basebox #{url.split('/').last} via packer"
                template_based_file_write(packerfile_path, packerfile_path.split(/.erb$/).first)
                template_based_file_write(autounattend_path, autounattend_path.split(/.erb$/).first)
                system "cd '#{packerfile_path.split(/\/[^\/]*.erb$/).first}' && packer build Packerfile && cd '#{ROOT_DIR}'"
              else
                Print.err "Packerfile not found, vagrant error may occur, please check the secgen metadata for the base module #{selected_module.name} for errors";
              end
            else
              Print.std "Vagrant basebox #{url.split('/').last} exists"
              selected_module.attributes['url'][0] = "#{VAGRANT_BASEBOX_STORAGE}/#{url}"
            end
          end
        end
      end
    end

    # Create environments/production/environment.conf - Required in Puppet 4+
    efile = "#{@out_dir}/environments/production/environment.conf"
    Print.std "Creating Puppet Environent file: #{efile}"
    FileUtils.touch(efile)

    vfile = "#{@out_dir}/Vagrantfile"
    Print.std "Creating Vagrant file: #{vfile}"
    template_based_file_write(VAGRANT_TEMPLATE_FILE, vfile)

    # Create the scenario xml file
    xfile = "#{@out_dir}/scenario.xml"

    xml_report_generator = XmlScenarioGenerator.new(@systems, @scenario, @time)
    xml = xml_report_generator.output
    Print.std "Creating scenario definition file: #{xfile}"
    begin
      File.open(xfile, 'w+') do |file|
        file.write(xml)
      end
    rescue StandardError => e
      Print.err "Error writing file: #{e.message}"
      abort
    end

    # Create the marker xml file
    x2file = "#{@out_dir}/flag_hints.xml"

    xml_marker_generator = XmlMarkerGenerator.new(@systems, @scenario, @time)
    xml = xml_marker_generator.output
    Print.std "Creating flags and hints file: #{x2file}"
    begin
      File.open(x2file, 'w+') do |file|
        file.write(xml)
      end
    rescue StandardError => e
      Print.err "Error writing file: #{e.message}"
      abort
    end

    # Create the CTFd zip file for import
    ctfdfile = "#{@out_dir}/CTFd_importable.zip"
    Print.std "Creating CTFd configuration: #{ctfdfile}"

    ctfd_generator = CTFdGenerator.new(@systems, @scenario, @time)
    ctfd_files = ctfd_generator.ctfd_files

    # zip up the CTFd export
    begin
      Zip::ZipFile.open(ctfdfile, Zip::ZipFile::CREATE) { |zipfile|
        zipfile.mkdir("db")
        ctfd_files.each do |ctfd_file_name, ctfd_file_content|
          zipfile.get_output_stream("db/#{ctfd_file_name}") { |f|
            f.print ctfd_file_content
          }
        end
        # zipfile.mkdir("uploads")
        # TODO: could add a logo image
        # zipfile.mkdir("uploads/uploads") # empty as in examples
        # zipfile.mkdir("uploads/fca9b07e1f3699e07870b86061815b1c")
        # zipfile.get_output_stream("uploads/fca9b07e1f3699e07870b86061815b1c/logo.svg") { |f|
        #   f.print File.readlines(ROOT_DIR + '/lib/resources/images/svg_icons/flag.svg')
        # }
      }
    rescue StandardError => e
      Print.err "Error writing zip file: #{e.message}"
      abort
    end


    Print.std "VM(s) can be built using 'vagrant up' in #{@out_dir}"

  end

# @param [Object] template erb path
# @param [Object] filename file to write to
  def template_based_file_write(template, filename)
    template_out = ERB.new(File.read(template), 0, '<>-')

    begin
      File.open(filename, 'wb+') do |file|
        file.write(template_out.result(self.get_binding))
      end
    rescue StandardError => e
      Print.err "Error writing file: #{e.message}"
      Print.err e.backtrace.inspect
    end
  end

# Resolves the network based on the scenario and ip_range.
# In the case that both command-line --network-ranges and datastores are provided, we have already handled the replacement of the ranges in the datastore.
# Because of this we prioritise datastore['IP_address'], then command line options (i.e. when no datastore is used, but the --network-ranges are passed), then the default network module's IP range.
  def resolve_network(network_module)
    current_network = network_module
    scenario_ip_range = network_module.attributes['range'].first

    # Prioritise datastore IP_address
    if current_network.received_inputs.include? 'IP_address'
      ip_address = current_network.received_inputs['IP_address'].first
    elsif @options.has_key? :ip_ranges
    # if we have options[:ip_ranges] we want to use those instead of the ip_range argument.
    # Store the mappings of scenario_ip_ranges => @options[:ip_range]  in @option_range_map
      # Have we seen this scenario_ip_range before? If so, use the value we've assigned
      if @option_range_map.has_key? scenario_ip_range
        ip_range = @option_range_map[scenario_ip_range]
      else
        # Remove options_ips that have already been used
        options_ips = @options[:ip_ranges]
        options_ips.delete_if { |ip| @option_range_map.has_value? ip }
        @option_range_map[scenario_ip_range] = options_ips.first
        ip_range = options_ips.first
      end
      ip_address = get_ip_from_range(ip_range)
    else
      ip_address = get_ip_from_range(scenario_ip_range)
    end
    ip_address
  end

  def get_ip_from_range(ip_range)
    # increment @scenario_networks{ip_range=>counter}
    @scenario_networks[ip_range] += 1

    # Split the range up and replace the last octet with the counter value
    split_ip = ip_range.split('.')
    last_octet = @scenario_networks[ip_range]
    last_octet = last_octet % 254

    # Replace the last octet in our split_ip array and return the IP
    split_ip[3] = last_octet.to_s
    split_ip.join('.')
  end

  # Replace 'network' with 'snoop' where the system name contains snoop
  def get_ovirt_network_name(system_name, network_name)
    split_name = network_name.split('-')
    split_name[1] = 'snoop' if system_name.include? 'snoop'
    split_name.join('-')
  end

# Returns binding for erb files (access to variables in this classes scope)
# @return binding
  def get_binding
    binding
  end

end
