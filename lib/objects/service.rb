class Service
  attr_accessor :attributes

  # Initialise Service object
  # @param name [String] service name
  # @param type [String] service range
  # @param details [String] service details
  # @param puppets [Array] puppet files used to create service
  def initialize(name="", type="", details="", puppets=[])
    @attributes = {
        :name => name,
        :type => type,
        :details => details,
        :puppets => puppets
    }

  end

  # Check if name matches services.xml from scenario.xml
  # @param other [String]
  # @return [Boolean] Returns true if @type matches services.xml from scenario.xml
  def eql? other
    other.kind_of?(self.class) && @attributes[:type] == other.type
  end

  # Returns a hash of the type
  # @return [Hash] hash of the object variable @type
  def hash
    @attributes[:type].hash
  end

  # Returns string containing the object type variable
  # @return [String] Services id string
  def id
    return @attributes[:type]
  end
end