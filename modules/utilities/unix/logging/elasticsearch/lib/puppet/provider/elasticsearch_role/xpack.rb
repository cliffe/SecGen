require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role).provide(
  :xpack,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :privileges
) do
  desc 'Provider for X-Pack role resources.'

  xpack_config 'roles.yml'
  confine :exists => default_target
end
