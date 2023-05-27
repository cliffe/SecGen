require 'nokogiri'
# Convert systems objects into xml
class XmlCybokGenerator

  # @param [Object] systems the list of systems
  # @param [Object] scenario the scenario file used to generate
  # @param [Object] time the current time as a string
  def initialize(systems, scenario, time)
    @systems = systems
    @scenario = scenario
    @time = time
  end

  # outputs a XML CyBOK file that can be used to track CyBOK
  # even for randomised challenges, where CyBOK is defined per module
  # @return [Object] xml string
  def output
    # $cybok_coverage starts with the cybok from the scenario, and then we also
    # add all the cybok from modules that are selected
    @systems.each { |system|
      system.module_selections.each { |selected_module|
        $cybok_coverage.push *selected_module.cybok_coverage
      }
    }
    coverage = "<cybokmapping>" + $cybok_coverage.map { |c| "\n        " + c.to_xml.gsub(/\R/, "\n      ").gsub(/\t/, '  ') }.uniq.join("\n") + "\n      " + "</cybokmapping>"

    doc = Nokogiri.XML(coverage)
    doc.to_xml
  end
end
