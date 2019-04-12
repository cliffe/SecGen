require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role).provide(
  :shield,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :privileges
) do
  desc 'Provider for Shield role resources.'

  shield_config 'roles.yml'
  confine :exists => default_target
end
