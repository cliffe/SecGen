require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role_mapping).provide(
  :xpack,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :mappings
) do
  desc 'Provider for X-Pack role mappings.'

  xpack_config 'role_mapping.yml'
  confine :exists => default_target
end
