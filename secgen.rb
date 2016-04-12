require 'getoptlong'
require 'fileutils'
require_relative 'lib/constants'
require_relative 'lib/filecreator.rb'
require_relative 'lib/systemreader.rb'
require_relative 'lib/vagrant.rb'
require_relative 'lib/helpers/bootstrap'


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

	# Initialise configuration
	config = Configuration.new()

	puts 'Creating vagrant file'
  # create's vagrant file / report a starts the vagrant installation'
	file_creator = FileCreator.new(config)
	build_number = file_creator.generate()
	return build_number
end

def build_vms(build_number)
  vagrant = VagrantController.new
  vagrant.vagrant_up(build_number)
end

def run
  build_number = build_config
  build_vms(build_number)
end

# end of method declarations
# start of program execution

puts 'SecGen - Creates virtualised security scenarios'
puts 'Licensed GPLv3 2014-16'

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






