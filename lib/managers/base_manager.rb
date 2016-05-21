class BaseManager
  # Generates a basebox system from a sample of the bases.xml file
  # @param system [Object] System object
  # @param bases [Array] Bases array
  # @return [Object] Basebox system
  def self.generate_base(system,bases)
    # takes a sample from bases.xml and then assigns it to system
    box = bases.sample
    system.attributes[:basebox] = box.attributes['vagrantbase']
    system.attributes[:url] = box.attributes['url']
    return system
  end
end