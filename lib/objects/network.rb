class Network
  #Network attributes hash
  attr_accessor :attributes

  # Initialise Network object
  # @param name [String] Network name
  # @param range [String] Network range
  def initialize(name="", range="")
    @attributes = {
        :name => name,
        :range => range
    }

  end

  # Returns a string containing all object variables concatenated together
  # @return [String] Hash containing @name and @range object variables as a concatenated string
  def id
    hash = @attributes[:name] + @attributes[:range]
    return hash
    # return string that connects everything to 1 massive string
  end

  # Check if name matches networks.xml from scenario.xml
  # @param other [String]
  # @return [Boolean] Returns true if @name matches networks.xml from scenario.xml
  def eql? other
    # checks if name matches networks.xml from scenario.xml
    other.kind_of?(self.class) && (@attributes['name'] == other.attributes[:name])
  end

  # Returns a hash of the type
  # @return [Hash] Hash of the object variable @type
  def hash
    @attributes[:type].hash
  end

end