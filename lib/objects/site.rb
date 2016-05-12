class Site
  # Site name
  attr_accessor :name

  # Type of site
  attr_accessor :type

  # Initialize site object
  # @param name [String]
  # @param type [String]
  def initialize(name='', type='')
    @name = name
    @type = type
  end
end