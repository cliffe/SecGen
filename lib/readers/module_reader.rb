require 'nokogiri'

require_relative '../helpers/constants.rb'
require_relative '../objects/module'
require_relative 'system_reader.rb'

class ModuleReader

  # reads in all bases
  def self.read_bases
    return read_modules('base', BASES_DIR, BASE_SCHEMA_FILE, false)
  end

  # reads in all build modules
  def self.read_builds
    return read_modules('build', BUILDS_DIR, BUILDS_SCHEMA_FILE, true)
  end

  # reads in all vulnerability modules
  def self.read_vulnerabilities
    return read_modules('vulnerability', VULNERABILITIES_DIR, VULNERABILITY_SCHEMA_FILE, true)
  end

  # reads in all services
  def self.read_services
    return read_modules('service', SERVICES_DIR, SERVICE_SCHEMA_FILE, true)
  end

  # reads in all utilities
  def self.read_utilities
    return read_modules('utility', UTILITIES_DIR, UTILITY_SCHEMA_FILE, true)
  end

  # reads in all forensics
  def self.read_forensics
    return read_modules('forensic', FORENSICS_DIR, FORENSICS_SCHEMA_FILE, true)
  end

  # reads in all utilities
  def self.read_generators
    return read_modules('generator', GENERATORS_DIR, GENERATOR_SCHEMA_FILE, true)
  end

  # reads in all utilities
  def self.read_encoders
    return read_modules('encoder', ENCODERS_DIR, ENCODER_SCHEMA_FILE, true)
  end

  # reads in all networks
  def self.read_networks
    return read_modules('network', NETWORKS_DIR, NETWORK_SCHEMA_FILE, false)
  end

  # reads in xml files to create modules
  # @param [Object] module_type 'vulnerability', 'base', etc
  # @param [Object] modules_dir ROOT_DIR path leading to 'modules/'
  # @param [Object] schema_file the xml schema that defines this type of module
  # @param [Object] require_puppet whether this kind of SecGen module has puppet code
  # @return [Object] the list of modules read
  def self.read_modules(module_type, modules_dir, schema_file, require_puppet)
    modules = []
    Dir.glob("#{modules_dir}**/**/secgen_metadata.xml").each do |file|
      module_path, module_filename = nil
      match = file.match(/#{ROOT_DIR}\/(.*?([^\/]*))\/secgen_metadata.xml/i)
      if match.captures.size == 2
        module_path, module_filename = match.captures
      else
        Print.err "Unexpected error extracting module path from #{file}"
        exit
      end

      Print.verbose "Reading #{module_type}: #{module_path}"
      doc, xsd = nil
      begin
        doc = Nokogiri::XML(File.read(file))
      rescue
        Print.err "Failed to read #{module_type} metadata file (#{file})"
        exit
      end

      # validate scenario XML against schema
      begin
        xsd = Nokogiri::XML::Schema(File.read(schema_file))
        xsd.validate(doc).each do |error|
          Print.err "Error in #{module_type} metadata file (#{file}):"
          Print.err '    ' + error.message
          exit
        end
      rescue Exception => e
        Print.err "Failed to validate #{module_type} metadata file (#{file}): against schema (#{schema_file})"
        Print.err e.message
        exit
      end

      # remove xml namespaces for ease of processing
      doc.remove_namespaces!

      new_module = Module.new(module_type)
      # save module path (and as an attribute for filtering)
      new_module.module_path = module_path
      new_module.attributes['module_path'] = [module_path]

      new_module.puppet_file = "#{ROOT_DIR}/#{module_path}/#{module_filename}.pp"
      new_module.puppet_other_path = "#{ROOT_DIR}/#{module_path}/manifests"

      # save executable path of any pre-calculation for outputs
      local = "#{module_path}#{MODULE_LOCAL_CALC_DIR}"
      if File.file?(local)
        new_module.local_calc_file = local
      end

      # check that the expected puppet files exist
      if require_puppet
        unless File.file?("#{new_module.puppet_file}")
          Print.err "Module #{module_path} missing required puppet init file (#{new_module.puppet_file})"
          exit
        end

        unless File.exists?("#{new_module.puppet_other_path}")
          Print.err "Module #{module_path} missing required puppet module manifests folder (#{new_module.puppet_other_path})"
          exit
        end
      end

      # for each element in the vulnerability
      doc.xpath("/#{module_type}/*").each do |module_doc|

        # new_module.attributes[module_doc.name] = module_doc.content

        # creates the array if null
        (new_module.attributes[module_doc.name] ||= []).push(module_doc.content)

      end

      # for each conflict in the module
      doc.xpath("/#{module_type}/conflict").each do |conflict_doc|
        conflict = {}
        conflict_doc.elements.each {|node|
          (conflict[node.name] ||= []).push(node.content)
        }
        new_module.conflicts.push(conflict)
      end

      # for each dependency in the module
      doc.xpath("/#{module_type}/requires").each do |requires_doc|
        require = {}
        requires_doc.elements.each {|node|
          (require[node.name] ||= []).push(node.content)
        }
        new_module.requires.push(require)
      end

      # for each default input
      doc.xpath("/#{module_type}/default_input").each do |inputs_doc|
        inputs_doc.xpath('descendant::vulnerability | descendant::service | descendant::utility | descendant::forensic | descendant::network | descendant::base | descendant::encoder | descendant::generator').each do |module_node|

          # create a selector module, which is a regular module instance used as a placeholder for matching requirements
          module_selector = Module.new(module_node.name)

          # create a unique id for tracking variables between modules
          module_selector.unique_id = "#{module_node.path}#{module_path}".gsub(/[^a-zA-Z0-9]/, '')
          # check if we need to be sending the module output to another module
          module_node.xpath('parent::input').each do |input|
            # Parent is input -- track that we need to send write value somewhere
            input.xpath('..').each do |input_parent|
              module_selector.write_output_variable = input.xpath('@into').to_s
              module_selector.write_to_module_with_id = "#{input_parent.path}#{module_path}".gsub(/[^a-zA-Z0-9]/, '')
            end
          end
          if module_node.xpath('parent::default_input').to_s != ''
            # input for this module -- track that we need to send write value to the module itself
            module_selector.write_output_variable = module_node.xpath('parent::default_input/@into').to_s

            module_selector.write_to_module_with_id = 'vulnerabilitydefaultinput'
          end

          # check if we are being passed an input *literal value*, into a module selector
          module_node.xpath('input/value').each do |input_value|
            variable = input_value.xpath('../@into').to_s
            value = input_value.text
            (module_selector.received_inputs[variable] ||= []).push(value)
          end

          into = module_node.xpath('ancestor::default_input/@into').to_s

          (new_module.default_inputs_selectors["#{into}"] ||= []).unshift(module_selector)

          module_node.xpath('@*').each do |attr|
            module_selector.attributes["#{attr.name}"] = [attr.text] unless attr.text.nil? || attr.text == ''
          end
          Print.verbose " #{module_node.name} (#{module_selector.unique_id}), selecting based on:"
          module_selector.attributes.each do |attr|
            if attr[0] && attr[1] && attr[0].to_s != "module_type"
              Print.verbose "  - #{attr[0].to_s} ~= #{attr[1].to_s}"
            end
          end
        end

        # check if we are being passed an input *literal value* -- to the containing module's default_value itself (as opposed to a module selector)
        inputs_doc.xpath('value').each do |input_value|
          variable = input_value.xpath('parent::default_input/@into').to_s
          value = input_value.text

          (new_module.default_inputs_literals[variable] ||= []).push(value)
        end
      end

      modules.push(new_module)
    end

    return modules
  end

end