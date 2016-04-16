class Service
  # attr_accessor :name, :type, :details, :puppets
  attr_accessor :attributes

  def initialize(name="", type="", details="", puppets=[])
    @attributes = {
        :name => name,
        :type => type,
        :details => details,
        :puppets => puppets
    }
    # @name = name
    # @type = type
    # @details = details
    # @puppets = puppets
  end

  def eql? other
    other.kind_of?(self.class) && @attributes[:type] == other.type
  end

  def hash
    @attributes[:type].hash
  end

  def id
    return @attributes[:type]
  end
end