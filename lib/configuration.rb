require_relative 'systemreader.rb'

class Configuration

  # populates the system class with an array of System objects.
  def initialize
    @systemreader = SystemReader.new
    @systems = init_systems()
  end

  def get_systems
    if @systems.empty?
      init_systems()
    end
    return @systems
  end

  def init_systems()
    @systems = @systemreader.parse_systems
  end

  def self.networks
    if defined? @@networks
      return @@networks
    end
    return @@networks = get_list(NETWORKS_XML, "//networks/network", Network)
  end

  def self.bases
    if defined? @@bases
      return @@bases
    end
    return @@bases = get_list(BASES_XML, "//bases/base", Basebox)
  end

    def self.services
    if defined? @@services
      return @@services
    end
    return @@services = get_list(SCENARIO_XML, "/systems/system/services/service", Service)
  end

  def self.get_list(xmlfile, xpath, cls)
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