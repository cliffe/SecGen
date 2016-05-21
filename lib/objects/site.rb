class Site
  #Site attributes hash
  attr_accessor :attributes

  # Initialize site object
  # @param name [String]
  # @param type [String]
  def initialize(name='', type='')
    @attributes = {
        :name => name,
        :type => type
    }

  end
end