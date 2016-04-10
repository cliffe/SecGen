class Site
  attr_accessor :name,
                :secure_plugins,
                :vulnerable_plugins,
                :theme,
                :users,
                :admin_user,
                :admin_password,
                :admin_email



  def initialize(name='',secure_plugins = [], vulnerable_plugins=[], theme='', users=[], admin_user='', admin_password='', admin_email='' )
    @name = name
    @secure_plugins = secure_plugins
    @vulnerable_plugins = vulnerable_plugins
    @theme = theme
    @users = users
    @admin_user = admin_user
    @admin_password = admin_password
    @admin_email = admin_email



  end
end