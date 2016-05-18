require 'xmlsimple'

# Convert systems objects into xml
class XMLReportGenerator

  # Initialize the class with the systems array and the current build number
  # @param systems [Array] Array of all systems objects
  # @param build_number [Int] Current build number of system
  def initialize(systems, build_number)
    @systems = systems
    @build_number = build_number
  end

  ### Start of private methods ###
  private

  ##
  # Generates hashes as an array for all network interfaces showing the system's ip
  # @param s [Array] Current system being generated
  # @return [Array] Array of all network hashes
  def get_networks_hash(s)
    networks_array = Array.new
    networks_hash = Hash.new

    s.attributes[:networks].each do |n|
      # grab_system_number = s.id.gsub(/[^0-9]/i, "")
      # n.range[9..9] = grab_system_number

      networks_hash['network'] = [n.attributes[:range] << '0']

      networks_array << networks_hash
    end
    return networks_array
  end

  ##
  # Generates hashes as an array for all services to be installed on the specific system
  # @param s [Array] Current system being generated
  # @return [Array] Array of all service hashes
  def get_services_hash(s)
    service_array = Array.new
    service_hash = Hash.new
    s.attributes[:services].each do |v|

      service_hash['type'] = [v.attributes[:type]] unless v.attributes[:type].empty?
      service_hash['name'] = [v.attributes[:name]] unless v.attributes[:name].empty?
      service_hash['details'] = [v.attributes[:details]] unless v.attributes[:details].empty?

      v.attributes[:puppets].each do |p|
        service_hash['puppet_file'] = ["#{p}.pp"]
      end
      service_array << service_hash
    end

    return service_array
  end

  # Generates hashes as an array for all vulnerabilities to be placed on the specific system
  # @param s [Array] Current system being generated
  # @return [Array] Array of all vulnerability hashes
  def get_vulnerabilities_hash(s)
    vulns_array = Array.new
    vulns_hash = Hash.new

    s.attributes[:vulns].each do |v|

      vulns_hash['type'] = [v.attributes[:type]] unless v.attributes[:type].empty?
      vulns_hash['details'] = [v.attributes[:details]] unless v.attributes[:details].empty?
      vulns_hash['privilege'] = [v.attributes[:privilege]] unless v.attributes[:privilege].empty?
      vulns_hash['access'] = [v.attributes[:access]] unless v.attributes[:access].empty?
      vulns_hash['cve'] = [v.attributes[:cve]] unless v.attributes[:cve].empty?
      vulns_hash['difficulty'] = [v.attributes[:difficulty]] unless v.attributes[:difficulty].empty?
      vulns_hash['cvss_rating'] = [v.attributes[:cvss_rating]] unless v.attributes[:cvss_rating].empty?
      vulns_hash['cvss_score'] = [v.attributes[:cvss_score]] unless v.attributes[:cvss_score].empty?
      vulns_hash['vector_string'] = [v.attributes[:vector_string]] unless v.attributes[:vector_string].empty?

      v.attributes[:puppets].each do |p|
        vulns_hash['puppet_file'] = ["#{p['puppet'][0]}.pp"]
      end
      vulns_array << vulns_hash
    end
    return vulns_array
  end

  # Generates hashes as an array for all sites to be placed on the specific system
  # @param s [Array] Current system being generated
  # @return [Array] Array of all vulnerability hashes
  def get_sites_hash(s)
    sites_array = Array.new
    sites_hash = Hash.new

    s.attributes[:sites].each do |v|

      sites_hash['name'] = [v.attributes[:name]] unless (v.attributes[:name].nil? || v.attributes[:name].empty?)
      sites_hash['type'] = [v.attributes[:type]] unless v.attributes[:type].empty?

      sites_array << sites_hash
    end
    return sites_array
  end

  # Creates a hash in the specific format for the XmlSimple library
  # @return [Hash] Hash compatible with XmlSimple
  def create_xml_hash
    hash = Hash.new
    @systems.each do |system|
      hash = {
          'id' => system.attributes[:id], 'basebox' => system.attributes[:basebox], 'os' => system.attributes[:os], 'url' => system.attributes[:url],
          'networks' => get_networks_hash(system),
          'services' => get_services_hash(system),
          'vulnerabilities' => get_vulnerabilities_hash(system),
          'sites' => get_sites_hash(system)
      }
    end
    return hash
  end

  ### Start of public methods ###
  public

  # Write the xml to an xml file
  def write_xml_report
    XmlSimple.xml_out(create_xml_hash,{:rootname => 'system',:OutputFile => "#{PROJECTS_DIR}/Project#{@build_number}/Report.xml"})
  end

  # Return the xml as a string
  # @return [String]
  def return_xml
    return XmlSimple.xml_out(create_xml_hash,{:rootname => 'system'})
  end

  # Print the xml to the console
  def print_xml
    puts XmlSimple.xml_out(create_xml_hash,{:rootname => 'system'})
  end
end