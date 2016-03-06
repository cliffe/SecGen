class Network
  attr_accessor :name, :range

  def initialize(name="", range="")
    @name = name
    @range = range
  end

  def id
    hash = @name + @range
    return hash
    # return string that connects everything to 1 massive string
  end

  def eql? other
    # checks if name matches networks.xml from scenario.xml
    other.kind_of?(self.class) && @name == other.name
  end

  def hash
    @type.hash
  end

end