class Network
  # Network name
  attr_accessor :name

  # Network range
  attr_accessor :range

  # Initialise Network object
  # @param name [String] Network name
  # @param range [String] Network range
  def initialize(name="", range="")
    @name = name
    @range = range
  end

  # Returns a string containing all object variables concatenated together
  # @return [String] Hash containing @name and @range object variables as a concatenated string
  def id
    hash = @name + @range
    return hash
    # return string that connects everything to 1 massive string
  end

  # Check if name matches networks.xml from scenario.xml
  # @param other [String]
  # @return [Boolean] Returns true if @name matches networks.xml from scenario.xml
  def eql? other
    # checks if name matches networks.xml from scenario.xml
    other.kind_of?(self.class) && @name == other.name
  end

  # Returns a hash of the type
  # @return [Hash] Hash of the object variable @type
  def hash
    @type.hash
  end

end