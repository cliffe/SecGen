require_relative 'systemreader.rb'

class Configuration

  # Populates the system class with an array of System objects.
  def initialize
    @systemreader = SystemReader.new
    @systems = init_systems()
  end

  # Return all systems
  # @return [Array] Array of systems objects
  def get_systems
    if @systems.empty?
      init_systems()
    end
    return @systems
  end

  # Initialise configuration of all systems
  def init_systems()
    @systems = @systemreader.parse_systems
  end

  # Returns the existing networks if defined, else returns network from the file networks.xml
  # @return [Array] Array of network objects
  def self.networks
    if defined? @@networks
      return @@networks
    end
    return @@networks = _get_list(NETWORKS_XML, "//networks/network", Network)
  end

  # Returns the existing bases if defined, else returns bases the from the file base.xml
  # @return [Array] Array of base_box objects
  def self.bases
    if defined? @@bases
      return @@bases
    end
    return @@bases = _get_list(BASE_XML, "//bases/base", Basebox)
  end

  # Returns the existing vulnerabilities if defined, else returns vulnerabilities the from the file vuln.xml
  # @return [Array] Array of vulnerability objects
  def self.vulnerabilities
    if defined? @@vulnerabilities
      return @@vulnerabilities
    end
    return @@vulnerabilities = _get_list(VULN_XML, "//vulnerabilities/vulnerability", Vulnerability)
  end

  # Returns the existing services if defined, else returns services the from the file services.xml
  # @return [Array] Array of service objects
    def self.services
    if defined? @@services
      return @@services
    end
    return @@services = _get_list(SCENARIO_XML, "/systems/system/services/service", Service)
  end

  # Reads xml file and returns relevent items
  # @param  xmlfile [File] Name of XML file to read
  # @param  xpath [String] Path to puppet files
  # @param  cls [Class] Class to be imported in
  # @return [Array] List containing all item from given xml file
  def self._get_list(xmlfile, xpath, cls)
    itemlist = []

    doc = Nokogiri::XML(File.read(xmlfile))
    doc.xpath(xpath).each do |item|
      # new class e.g networks
      obj = cls.new
      # checks to see if there are children puppet and add string to obj.puppets
      # move this to vulnerabilities/services classes?
      if defined? obj.puppets
        item.xpath("puppets/puppet").each { |c| obj.puppets << c.text.strip if not c.text.strip.empty? }
        item.xpath("ports/port").each { |c| obj.ports << c.text.strip if not c.text.strip.empty? }
      end
      # too specific move to vuln class end
      item.each do |attr, value|

        obj.send "#{attr}=", value
      end
      # vulnerability item
      itemlist << obj
    end
    return itemlist
  end
end