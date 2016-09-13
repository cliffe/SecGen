class ScenarioFileCreator
  def self.build_scenario(scenario_tmp_file, options)
    scenario_tmp_file.path

    puts options

    ns = {
            'xmlns' => "http://www.github/cliffe/SecGen/scenario",
            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
            'xsi:schemaLocation' => "http://www.github/cliffe/SecGen/scenario"
        }

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.scenario (ns) {
        xml.system {
          xml.system_name "#{options[:module]}_test_system"
          xml.base(:platform => options[:basebox_type])
          case options[:module_type]
            when 'vulnerability'
              xml.vulnerability(:module_path => options[:module])
            when 'service'
              xml.service(:module_path => options[:module])
            when 'utility'
              xml.utility(:module_path => options[:module])
            else
              puts "Unexpected module type: #{options[:module_type]}"
              exit
          end
          xml.network(:type => options[:network_type], :range => 'dhcp')
        }
      }
    end

    scenario_tmp_file.write(builder.doc)

    return scenario_tmp_file
  end
end