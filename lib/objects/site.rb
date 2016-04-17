class Site
  attr_accessor :attributes

  def initialize(name='', type='')
    @attributes = {
        :name => name,
        :type => type
    }

  end
end