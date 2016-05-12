require_relative '../helpers/plugin_helper'
class PluginManager

  def initialize
    @plugin_helper = PluginHelper.new
  end


  def process_vulnerable_plugins(vulnerable_scenario_plugins, valid_vulnerable_plugins)

    vulnerable_plugins = []
    vulnerable_scenario_plugins.each do |scenario_plugin|
      search_list = valid_vulnerable_plugins.clone
      search_list.shuffle!
      #name is absolute, so should be filtered upon first and all other filtering should be skipped.
      if scenario_plugin.name.length > 0
        puts "Searching for plugin matching name #{scenario_plugin.name}"
        search_list.delete_if{|v| v.name != scenario_plugin.name }
      end

      #filter by type
      if scenario_plugin.vulnerability_type.length > 0
        puts "Searching for plugin matching vulnerability type #{scenario_plugin.vulnerability_type}"
        search_list.delete_if{|v| v.vulnerability_type != scenario_plugin.vulnerability_type}
      end
      selected_plugin = search_list.sample
      puts "Selected plugin: #{selected_plugin.name}"
      vulnerable_plugins << selected_plugin
    end

    return vulnerable_plugins
  end

  def process_secure_plugins(secure_scenario_plugins, valid_secure_plugins)

    secure_plugins = []
    secure_scenario_plugins.each do |scenario_plugin|
      search_list = valid_secure_plugins.clone
      search_list.shuffle!
      #name is absolute, so should be filtered upon first and all other filtering should be skipped.
      if scenario_plugin.name.length > 0
        puts "Searching for plugin matching name #{scenario_plugin.name}"
        search_list.delete_if{|v| v.name != scenario_plugin.name }
        if search_list.length == 0
          puts "The requested plugin: #{scenario_plugin.name} could not be found."
          exit
        else
          selected_plugin = search_list.sample
          puts "Selected plugin: #{selected_plugin.name}"
          secure_plugins << selected_plugin
          next
        end
      else
        selected_plugin = search_list.sample
        puts "Selected plugin: #{selected_plugin.name}"
        secure_plugins << selected_plugin
      end

      return secure_plugins

    end
  end

  #gets all metadata under the vulnerabilities/unix/webapp directory
  def get_vulnerable_plugins_array
    vulnerable_plugins = []
    Dir.glob("#{ROOT_DIR}/modules/vulnerabilities/**/webapp/**/secgen_metadata.xml").each do |file|
      plugin_hash = XmlSimple.xml_in(file, {})
      plugin = @plugin_helper.get_vulnerable_plugin_object(plugin_hash)
      if plugin.platform == 'wordpress'
        vulnerable_plugins << plugin
      end
    end
    return vulnerable_plugins
  end

  def get_secure_plugins_array
    secure_plugins = []
    Dir.glob("#{ROOT_DIR}/modules/services/**/webapp/**/secgen_metadata.xml").each do |file|
      plugin_hash = XmlSimple.xml_in(file, {})
      plugin = @plugin_helper.get_secure_plugin_object(plugin_hash)
      if plugin.platform == 'wordpress'
        secure_plugins << plugin
      end
    end
    return secure_plugins
  end
end