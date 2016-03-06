class Service
  attr_accessor :name, :type, :details, :puppets

  def initialize(name="", type="", details="", puppets=[])
    @name = name
    @type = type
    @details = details
    @puppets = puppets
  end

  def eql? other
    other.kind_of?(self.class) && @type == other.type
  end

  def hash
    @type.hash
  end

  def id
    return @type
  end
end