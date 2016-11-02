require 'nokogiri'
require 'digest'

require_relative '../objects/system'
require_relative '../objects/module'

class SystemReader

  # uses nokogiri to extract all system information from scenario.xml
  # This includes module filters, which are module objects that contain filters for selecting
  # from the actual modules that are available
  # @return [Array] Array containing Systems objects
  def self.read_scenario(scenario_file)
    systems = []
    Print.verbose "Reading scenario file: #{scenario_file}"
    doc, xsd = nil
    begin
      doc = Nokogiri::XML(File.read(scenario_file))
    rescue
      Print.err "Failed to read scenario configuration file (#{scenario_file})"
      exit
    end

    # validate scenario XML against schema
    begin
      xsd = Nokogiri::XML::Schema(File.open(SCENARIO_SCHEMA_FILE))
      xsd.validate(doc).each do |error|
        Print.err "Error in scenario configuration file (#{scenario_file}):"
        Print.err '    ' + error.message
        exit
      end
    rescue Exception => e
      Print.err "Failed to validate scenario configuration file (#{scenario_file}): against schema (#{SCENARIO_SCHEMA_FILE})"
      Print.err e.message
      exit
    end

    # remove xml namespaces for ease of processing
    doc.remove_namespaces!

    doc.xpath('/scenario/system').each do |system_node|
      module_selectors = []
      system_attributes = {}

      system_name = system_node.at_xpath('system_name').text
      Print.verbose "system: #{system_name}"

      # system attributes, such as basebox selection
      system_node.xpath('@*').each do |attr|
        system_attributes["#{attr.name}"] = attr.text unless attr.text.nil? || attr.text == ''
      end

      # for each module selection
      system_node.xpath('//vulnerability | //service | //utility | //network | //base | //encoder | //generator | //build').each do |module_node|
        # create a selector module, which is a regular module instance used as a placeholder for matching requirements
        module_selector = Module.new(module_node.name)

        # create a unique id for tracking variables between modules
        module_selector.unique_id = module_node.path.gsub(/[^a-zA-Z0-9]/, '')
        # check if we need to be sending the module output to another module
        module_node.xpath('parent::input').each do |input|
          # Parent is input -- track that we need to send write value somewhere
          input.xpath('..').each do |input_parent|
            module_selector.write_output_variable = input.xpath('@into').to_s
            module_selector.write_to_module_with_id = input_parent.path.gsub(/[^a-zA-Z0-9]/, '')
          end
        end

        # check if we are being passed an input *literal value*
        module_node.xpath('input/value').each do |input_value|
          variable = input_value.xpath('../@into').to_s
          value = input_value.text
          Print.verbose "  -- literal value: #{variable} = #{value}"
          (module_selector.received_inputs[variable] ||= []).push(value)
        end


        module_node.xpath('@*').each do |attr|
          module_selector.attributes["#{attr.name}"] = [attr.text] unless attr.text.nil? || attr.text == ''
        end
        Print.verbose " #{module_node.name} (#{module_selector.unique_id}), selecting based on:"
        module_selector.attributes.each do |attr|
          if attr[0] && attr[1] && attr[0].to_s != "module_type"
            Print.verbose "  - #{attr[0].to_s} ~= #{attr[1].to_s}"
          end
        end

        # insert into module list
        # if this module feeds output to another, ensure list order makes sense for processing...
        if module_selector.write_output_variable != nil
          Print.verbose "  -- writes to: #{module_selector.write_to_module_with_id} - #{module_selector.write_output_variable}"
          # insert into module list before the module we are writing to
          insert_pos = -1 # end of list
          for i in 0..module_selectors.size-1
            if module_selector.write_to_module_with_id == module_selectors[i].unique_id
              # found position of earlier module this one feeds into, so put this one first
              insert_pos = i
            end
          end
          module_selectors.insert(insert_pos, module_selector)
        else
          # otherwise just append module to end of list
          module_selectors << module_selector
        end

      end
      systems << System.new(system_name, system_attributes, module_selectors)
    end

    return systems
  end
end