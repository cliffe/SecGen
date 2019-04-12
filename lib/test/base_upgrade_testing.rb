################################################################################
#
#  Script for generating test scenarios for identifying conflicts and
#  version mismatches within a recently upgraded base box.
#
#  Requires: SecGen batch database configured, see README-Batch-VMs.md
#
#  1) A scenario file is created for each software module within lib/test/tmp/
#  2) a batch_secgen entry is created for each generated scenario
#  3) batch_secgen spins up each scenario and reports on failures
#
################################################################################

require 'fileutils'

require_relative '../helpers/print.rb'
require_relative '../helpers/constants.rb'
require_relative '../../lib/readers/module_reader.rb'
require_relative '../output/xml_scenario_generator.rb'
require_relative '../objects/system'
require_relative '../objects/module'

@path_to_ruby = '/usr/bin/ruby'
@network_module = ''

def select_base
  bases = ModuleReader.read_bases
  Print.info 'Now listing all available bases: '

  bases.each_with_index do |base, i|
    Print.info "#{i}: #{base.attributes['name'][0]} at #{base.attributes['module_path'][0]}"
  end

  Print.info 'Input the index for the base you want to generate test scenarios for:'
  user_index = gets.chomp.to_i
  selected_base = bases[user_index]
  Print.info "You have selected: #{selected_base.attributes['name'][0]} at #{selected_base.attributes['module_path'][0]}"

  selected_base
end

def get_network_module
  if @network_module == ''
    @network_module = Module.new('network')
    @network_module.attributes['type'] = ['private_network']
  end
  @network_module
end

def generate_scenarios(selected_base)
  tmp_dir = "#{ROOT_DIR}/lib/test/tmp"

  Dir.mkdir tmp_dir unless Dir.exists? tmp_dir
  unless Dir.entries(tmp_dir).size == 2
    Print.info 'The temporary scenario directory (lib/test/tmp) contains files. Do you want to remove them? [Y/n]'
    input = STDIN.gets.chomp
    unless input == 'N' or input == 'n'
      Print.info 'Removing lib/test/tmp'
      FileUtils.rm_r(Dir.glob(tmp_dir))
      Print.info 'Creating lib/test/tmp'
      Dir.mkdir tmp_dir
    end
  end

  # Get installable software modules (vulns, services, utilities)

  vulnerabilities = ModuleReader.read_vulnerabilities
  services = ModuleReader.read_services
  utilities = ModuleReader.read_utilities

  available_software_modules = vulnerabilities + services + utilities

  # If the module conflicts with the base, remove it.
  available_software_modules.delete_if do |module_for_possible_exclusion|
    (module_for_possible_exclusion.conflicts_with(selected_base) ||
        selected_base.conflicts_with(module_for_possible_exclusion))
  end

  output_scenario_paths = []

  available_software_modules.each_with_index do |mod, i|
    ## Create a system_name based on the selected module and the base name
    system_name = mod.module_path_end

    # Clean up name
    system_name = system_name.gsub(/ /, '_')
    system_name = system_name.gsub(/\//, '')

    module_selections = []
    module_selections << selected_base
    module_selections << mod
    module_selections << get_network_module

    system = System.new(system_name, {}, [])
    system.module_selections = module_selections

    xml_generator = XmlScenarioGenerator.new([system], system_name, Time.new.to_s)
    xml_content = xml_generator.output

    output_filename = "#{tmp_dir}/#{i}.xml"
    Print.std "Creating scenario definition file: #{output_filename}"
    begin
      File.open(output_filename, 'w+') do |file|
        file.write(xml_content)
      end
      output_scenario_paths << output_filename
    rescue StandardError => e
      Print.err "Error writing file: #{e.message}"
      abort
    end
  end
  output_scenario_paths
end

def add_to_secgen_batch(scenario_paths)
  Print.info 'Do you want to add the generated test scenarios to the batch? [Y/n]'
  input = STDIN.gets.chomp
  unless input == 'N' or input == 'n'
    Print.info "Adding #{scenario_paths.size} jobs to batch queue"
    scenario_paths.each do |scenario_path|
      puts `#{@path_to_ruby} #{ROOT_DIR}/lib/batch/batch_secgen.rb add --instances test --- -s #{scenario_path} --read-options #{ROOT_DIR}/secgen.conf r`
    end
  end
end

Print.info 'Script for generating base module upgrade test scenarios'
base = select_base
output_scenario_paths = generate_scenarios(base)
Print.info 'Scenario files generated successfully.'
add_to_secgen_batch(output_scenario_paths)