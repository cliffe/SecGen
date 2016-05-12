require_relative '../objects/wordpress/secure_plugin'
require_relative '../objects/wordpress/vulnerable_plugin'
class PluginHelper
  def get_vulnerable_plugin_object(plugin_hash)
    vulnerable_plugin_object = VulnerablePlugin.new
    vulnerable_plugin_object.name = plugin_hash['name'] if plugin_hash['name']
    vulnerable_plugin_object.vulnerability_type = plugin_hash['vulnerability_type'] if plugin_hash['vulnerability_type']
    vulnerable_plugin_object.details = plugin_hash['details'] if plugin_hash['details']
    vulnerable_plugin_object.platform = plugin_hash['platform'] if plugin_hash['platform']

    vulnerable_plugin_object.msf_module = plugin_hash['msf_module'] if plugin_hash['msf_module']
    vulnerable_plugin_object.download_url = plugin_hash['download_url'] if plugin_hash['download_url']

    return vulnerable_plugin_object

  end

  def get_secure_plugin_object(plugin_hash)
    secure_plugin_object = SecurePlugin.new
    secure_plugin_object.name = plugin_hash['name'] if plugin_hash['name']
    secure_plugin_object.details = plugin_hash['details'] if plugin_hash['details']
    secure_plugin_object.platform = plugin_hash['platform'] if plugin_hash['platform']
    secure_plugin_object.download_url = plugin_hash['download_url'] if plugin_hash['download_url']

    return secure_plugin_object
  end
end