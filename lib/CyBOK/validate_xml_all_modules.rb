require 'nokogiri/class_resolver'
require 'nokogiri'

require_relative '../helpers/print.rb'
require_relative '../helpers/constants.rb'

@num_modules_processed = 0
@num_errors = 0

def check_modules(type, modules_dir, schema)
  Print.std "Reading #{type} modules! ***************************"
  modules = []
  # Get a list of all the modules
  Dir.chdir(modules_dir) do
    modules = Dir["**/secgen_metadata.xml"].sort
  end

  modules.each { |mod|
    # Print.verbose "Reading #{mod}"
    @num_modules_processed = @num_modules_processed + 1
    doc, xsd = nil
    begin
      doc = Nokogiri::XML(File.read("#{modules_dir}/#{mod}"))
    rescue
      Print.err "Failed to read module file (#{mod})"
    end

    # validate scenario XML against schema
    begin
      xsd = Nokogiri::XML::Schema(File.open(schema))
      xsd.validate("#{modules_dir}/#{mod}").each do |error|
        Print.err " Error in module file - #{mod}:"
        Print.err "    #{error.line}: #{error.message}"
        @num_errors = @num_errors + 1

      end
      Print.info " Valid XML - #{mod}"

    rescue Exception => e
      Print.err "Failed to validate module XML (#{mod}): against schema (#{VULNERABILITY_SCHEMA_FILE})"
      Print.err e.message
      @num_errors = @num_errors + 1
    end
  }
end

check_modules("vulnerability", "#{ROOT_DIR}/modules/vulnerabilities", VULNERABILITY_SCHEMA_FILE)
check_modules("service", "#{ROOT_DIR}/modules/services", SERVICE_SCHEMA_FILE)
check_modules("utility", "#{ROOT_DIR}/modules/utilities", UTILITY_SCHEMA_FILE)
check_modules("generator", "#{ROOT_DIR}/modules/generators", GENERATOR_SCHEMA_FILE)
check_modules("encoder", "#{ROOT_DIR}/modules/encoders", ENCODER_SCHEMA_FILE)
check_modules("base", "#{ROOT_DIR}/modules/bases", BASE_SCHEMA_FILE)

Print.std "Tested validation of #{@num_modules_processed} modules"
Print.std "#{@num_errors} errors"
