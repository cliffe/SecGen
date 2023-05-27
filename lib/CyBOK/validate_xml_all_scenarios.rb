require 'nokogiri/class_resolver'
require 'nokogiri'

require_relative '../helpers/print.rb'
require_relative '../helpers/constants.rb'

Print.std "Reading scenarios! ***************************"
scenarios = []
# Get a list of all the scenarios
scenarios_dir = "#{ROOT_DIR}/scenarios"
Dir.chdir(scenarios_dir) do
  scenarios = Dir["**/*.xml"].sort
end

scenarios.each { |scenario|
  # Print.verbose "Reading #{scenario}"
  doc, xsd = nil
  begin
    doc = Nokogiri::XML(File.read("#{ROOT_DIR}/scenarios/#{scenario}"))
  rescue
    Print.err "Failed to read scenario configuration file (#{scenario})"
  end

  # validate scenario XML against schema
  begin
    xsd = Nokogiri::XML::Schema(File.open(SCENARIO_SCHEMA_FILE))
    xsd.validate("#{ROOT_DIR}/scenarios/#{scenario}").each do |error|
      Print.err "Error in scenario configuration file (#{scenario}):"
      Print.err "    #{error.line}: #{error.message}"
    end
    Print.info " Valid XML - #{scenario}"
  rescue Exception => e
    Print.err "Failed to validate scenario configuration file (#{scenario}): against schema (#{SCENARIO_SCHEMA_FILE})"
    Print.err e.message
  end



}
