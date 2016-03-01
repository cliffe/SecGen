class Conf
  # this class uses nokogiri to grab all of the information from misc.xml, bases.xml, and vulns.xml
  # then adds them to their specific class to do checking for legal in Manager.process
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