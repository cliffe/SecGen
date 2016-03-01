require 'getoptlong'
require 'fileutils'
require_relative 'lib/constants'
require_relative 'lib/filecreator.rb'
require_relative 'lib/systemreader.rb'
require_relative 'lib/vagrant.rb'
require_relative 'lib/helpers/bootstrap'

# coloured logo
puts "\e[34m"
File.open('lib/commandui/logo/logo.txt', 'r') do |f1|
	while line = f1.gets
		puts line
	end
end
puts "\e[0m"

def usage
  puts 'Usage:
   ' + $0 + ' [options]

   OPTIONS:
   --run, -r: builds vagrant config and then builds the VMs
   --build-config, -c: builds vagrant config, but does not build VMs
   --build-vms, -v: builds VMs from previously generated vagrant config
   --help, -h: shows this usage information
'
  exit
end

def build_config
  puts 'Reading configuration file for virtual machines you want to create'

  # uses nokogoiri to grab all the system information from scenario.xml
  systems = SystemReader.new.systems

  puts 'Creating vagrant file'
  # create's vagrant file / report a starts the vagrant installation'
  create_files = FileCreator.new(systems)
  build_number = create_files.generate(systems)
  return build_number
end

def build_vms(build_number)
  vagrant = VagrantController.new
  vagrant.vagrant_up(build_number)
end

def run
  build_number = build_config()
  build_vms(build_number)
end

if ARGV.length < 1
	puts 'Please enter a command option.'
	puts
	usage
end

opts = GetoptLong.new(
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--run', '-r', GetoptLong::NO_ARGUMENT ],
	[ '--build-config', '-c', GetoptLong::NO_ARGUMENT ],
	[ '--build-vms', '-v', GetoptLong::NO_ARGUMENT ]  
)

opts.each do |opt, arg|
	case opt
		when '--help'
			usage
    when '--run'
      application_bootstrapper = Bootstrap.new
      application_bootstrapper.bootstrap
			run
		when '--build-config'
			build_config()
		when '--build-vms'
			build_vms()
	end
end






