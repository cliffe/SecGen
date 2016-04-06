class Site
  attr_accessor :name, :type, :vulnerable_plugins, :secure_plugins, :theme, :post_count, :users

  def initialize(name='', type='', )
    @name = name
    @type = type

  end
end