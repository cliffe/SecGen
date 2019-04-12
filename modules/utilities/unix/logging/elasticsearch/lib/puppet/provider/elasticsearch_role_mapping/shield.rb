require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role_mapping).provide(
  :shield,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :mappings
) do
  desc 'Provider for Shield role mappings.'

  shield_config 'role_mapping.yml'
  confine :exists => default_target
end
