class Network
  # attr_accessor :name, :range
  attr_accessor :attributes

  def initialize(name="", range="")
    @attributes = {
        :name => name,
        :range => range
    }

    @name = name
    @range = range
  end

  def id
    hash = @attributes[:name] + @attributes[:range]
    return hash
    # return string that connects everything to 1 massive string
  end

  def eql? other
    # checks if name matches networks.xml from scenario.xml
    other.kind_of?(self.class) && @attributes[:name] == other.name
  end

  def hash
    @attributes[:type].hash
  end

end