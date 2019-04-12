require 'puppet/provider/elastic_kibana'

Puppet::Type.type(:kibana_plugin).provide(
  :kibana_plugin,
  :parent => Puppet::Provider::ElasticKibana,
  :home_path => File.join(%w[/ usr share kibana]),
  :install_args => ['install'],
  :plugin_directory => 'plugins',
  :remove_args => ['remove']
) do
  desc 'Native command-line provider for Kibana v5 plugins.'

  commands :plugin => File.join(home_path, 'bin', 'kibana-plugin')
end
