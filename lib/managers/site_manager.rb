require_relative '../helpers/site_helper'
class SiteManager

  def initialize
    @site_helper = SiteHelper.new
  end

  def process(site)
    if site.theme.length == 0
      site.theme = get_random_theme_name
    end
    scenario_vulnerable_plugins = site.vulnerable_plugins
    scenario_secure_plugins = site.secure_plugins

  end

  private


  def get_random_theme_name
    themes_xml = Nokogiri::XML(File.read(THEMES_XML))
    selected_node = themes_xml.xpath('/themes/theme').to_a.sample
    name = selected_node['name']
    return name
  end
end