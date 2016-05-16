require 'erb'
require_relative 'erb_controller'
require_relative 'constants'
require_relative 'configuration'
require_relative 'xml_report_generator'
require 'fileutils'

class FileCreator
# Creates project directory, uses .erb files to create a report and the vagrant file that will be used
# to create the virtual machines

  # Initialises configuration variable
  # @param config [Object]
	def initialize(config)
		@configuration = config
	end

  # Generate all relevant files for the project
  # @return [Int] Build number of the newly generated project
	def generate()
		systems = @configuration.get_systems
		Dir::mkdir("#{PROJECTS_DIR}") unless File.exists?("#{PROJECTS_DIR}")

		count = Dir["#{PROJECTS_DIR}/*"].length
		build_number = count.next


		puts "The system is now creating the Project#{build_number}"
		Dir::mkdir("#{PROJECTS_DIR}/Project#{build_number}") unless File.exists?("#{PROJECTS_DIR}/#{build_number}")
		puts 'Creating the projects mount directory'
		Dir::mkdir("#{PROJECTS_DIR}/Project#{build_number}/mount") unless File.exists?("#{PROJECTS_DIR}/Project#{build_number}/mount")

		# initialises box before creation
		command = "cd #{PROJECTS_DIR}/Project#{build_number}/; vagrant init"
		%x[#{command}] 

		controller = ERBController.new
		controller.systems = systems
		vagrant_template = ERB.new(File.read(VAGRANT_TEMPLATE_FILE), 0, '<>')
		if File.exists?("#{PROJECTS_DIR}/Project#{build_number}/Vagrantfile")
      File.delete("#{PROJECTS_DIR}/Project#{build_number}/Vagrantfile")
    end
		puts "#{PROJECTS_DIR}/Project#{build_number}/Vagrantfile file has been created"
		File.open("#{PROJECTS_DIR}/Project#{build_number}/Vagrantfile", 'w') { |file| file.write(vagrant_template.result(controller.get_binding)) }

    # Create the Report file
		report_template = ERB.new(File.read(REPORT_TEMPLATE_FILE), 0, '<>')
		puts "#{PROJECTS_DIR}/Project#{build_number}/Report file has been created"
		File.open("#{PROJECTS_DIR}/Project#{build_number}/Report", 'w'){ |file| file.write(report_template.result(controller.get_binding)) }

    # Create the Report.xml file
    xml_report_generator = XMLReportGenerator.new(systems, build_number)
    xml_report_generator.write_xml_report
    puts "#{PROJECTS_DIR}/Project#{build_number}/Report.xml file has been created"

    return build_number
	end
end