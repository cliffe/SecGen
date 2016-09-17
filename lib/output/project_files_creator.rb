require 'erb'
require_relative '../helpers/constants.rb'
require_relative 'xml_report_generator.rb'
require 'fileutils'
require 'librarian'

class ProjectFilesCreator
# Creates project directory, uses .erb files to create a report and the vagrant file that will be used
# to create the virtual machines
  @systems
  @currently_processing_system

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

  end

# Generate all relevant files for the project
  def write_files
    FileUtils.mkpath "#{@out_dir}" unless File.exists?("#{@out_dir}")
    FileUtils.mkpath "#{@out_dir}/puppet/" unless File.exists?("#{@out_dir}/puppet/")

    threads = []
    # for each system, create a puppet modules directory using librarian-puppet
    @systems.each do |system|
      @currently_processing_system = system # for template access
      path = "#{@out_dir}/puppet/#{system.name}"
      FileUtils.mkpath(path) unless File.exists?(path)
      pfile = "#{path}/Puppetfile"
      Print.std "Creating Puppet modules librarian-puppet file: #{pfile}"
      template_based_file_write(PUPPET_TEMPLATE_FILE, pfile)
      Print.std 'Preparing puppet modules using librarian-puppet'
      GemExec.exe('librarian-puppet', path, 'install')
    end

    vfile = "#{@out_dir}/Vagrantfile"
    Print.std "Creating Vagrant file: #{vfile}"
    template_based_file_write(VAGRANT_TEMPLATE_FILE, vfile)

    # Create the Report.xml file
    xfile = "#{@out_dir}/scenario.xml"

    xml_report_generator = XMLReportGenerator.new(@systems, @scenario, @time)
    xml = xml_report_generator.output
    Print.std "Creating scenario definition file: #{xfile}"
    begin
      File.open(xfile, 'w+') do |file|
        file.write(xml)
      end
    rescue StandardError => e
      Print.err "Error writing file: #{e.message}"
      exit
    end
  end

# @param [Object] template erb path
# @param [Object] filename file to write to
  def template_based_file_write(template, filename)
    template_out = ERB.new(File.read(template), 0, '<>-')

    begin
      File.open(filename, 'w+') do |file|
        file.write(template_out.result(self.get_binding))
      end
    rescue StandardError => e
      Print.err "Error writing file: #{e.message}"
      exit
    end
  end

# Returns binding for erb files (access to variables in this classes scope)
# @return binding
  def get_binding
    binding
  end

end
