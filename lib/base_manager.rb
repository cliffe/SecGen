class BaseManager
  def self.generate_base(system,bases)
    # takes a sample from bases.xml and then assigns it to system
    box = bases.sample
    system.basebox = box.vagrantbase
    system.url = box.url
    return system
  end
end