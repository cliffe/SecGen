require 'puppet/provider/elastic_kibana'

Puppet::Type.type(:kibana_plugin).provide(
  :kibana,
  :parent => Puppet::Provider::ElasticKibana,
  :format_url => lambda { |url, b| [b.eval('resource[:name]'), '--url', url] },
  :home_path => File.join(%w[/ opt kibana]),
  :install_args => ['plugin', '--install'],
  :plugin_directory => 'installedPlugins',
  :remove_args => ['plugin', '--remove']
) do
  desc 'Native command-line provider for Kibana v4 plugins.'

  commands :plugin => File.join(home_path, 'bin', 'kibana')
end
