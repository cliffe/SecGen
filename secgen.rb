require 'getoptlong'
require_relative 'lib/constants'
require_relative 'lib/filecreator.rb'
require_relative 'lib/helpers/bootstrap'

@build_number

def print_help
  puts 'Usage:
   ' + $0 + ' [options]

   OPTIONS:
   --run, -r: builds vagrant config and then builds the VMs
   --build-config, -c: builds vagrant config, but does not build VMs
   --build-vms, -v: builds VMs from previously generated vagrant config
   --help, -h: shows this usage information'
  exit
end

def build_config
  puts 'Reading configuration file for virtual machines you want to create'
	# Initialise configuration
	config = Configuration.new
  # create's vagrant file / report a starts the vagrant installation'
	@build_number = FileCreator.new(config).generate
end

def vagrant_up
	#executes vagrant up from the current build.
	puts 'Building now.....'
	exec "cd #{PROJECTS_DIR}/Project#{@build_number}/; vagrant up"
end

def run
	Bootstrap.new.bootstrap
	build_config
	vagrant_up
end

# end of method declarations
# start of program execution

puts 'SecGen - Creates virtualised security scenarios'
puts 'Licensed GPLv3 2014-16'

if ARGV.length < 1
	puts 'Please enter a command option.'
	puts
	print_help
end

opts = GetoptLong.new(
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--run', '-r', GetoptLong::NO_ARGUMENT ],
	[ '--build-config', '-c', GetoptLong::NO_ARGUMENT ],
	[ '--build-vms', '-v', GetoptLong::NO_ARGUMENT ]  
)

for opt in opts do
	case opt
		when '--help'
			print_help
    when '--run'
      run
		when '--build-config'
			build_config
  end
end