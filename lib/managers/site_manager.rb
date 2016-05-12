require_relative '../helpers/site_helper'
require_relative '../managers/plugin_manager'
require 'nokogiri'
class SiteManager

  def initialize
    @site_helper = SiteHelper.new
    @plugin_manager = PluginManager.new
  end

  def process(site)
    random_user = get_random_user

    if site.name.length == 0
      site.name = 'wordpress'
    end

    if site.theme.length == 0
      site.theme = get_random_theme_name
    end

    if site.admin_user.length == 0
      site.admin_user = random_user.name
    end

    if site.admin_password.length == 0
      site.admin_password = random_user.password
    end

    if site.admin_email.length == 0
      site.admin_email = random_user.email
    end

    valid_vulnerable_plugins = @plugin_manager.get_vulnerable_plugins_array
    valid_secure_plugins = @plugin_manager.get_secure_plugins_array

    if site.vulnerable_plugins.count > 0
      site.vulnerable_plugins = @plugin_manager.process_vulnerable_plugins(site.vulnerable_plugins, valid_vulnerable_plugins)
    end
    if site.secure_plugins.count > 0
      site.secure_plugins = @plugin_manager.process_secure_plugins(site.secure_plugins, valid_secure_plugins)

    end

    return site

  end

  #return [String]
  def get_random_theme_name
    themes_xml = Nokogiri::XML(File.read(THEMES_XML))
    selected_node = themes_xml.xpath('/themes/theme').to_a.sample
    name = selected_node['name']
    return name
  end

  #return [User]
  def get_random_user
    users_xml = Nokogiri::XML(File.read(USERS_XML))
    selected_node = users_xml.xpath('/users/user').to_a.sample
    user = User.new(selected_node['username'], selected_node['password'], selected_node['email'])
    return user
  end






end