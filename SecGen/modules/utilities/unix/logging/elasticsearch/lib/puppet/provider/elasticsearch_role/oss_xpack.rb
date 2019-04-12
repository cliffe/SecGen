require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role).provide(
  :oss_xpack,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :privileges
) do
  desc 'Provider for OSS X-Pack role resources.'

  oss_xpack_config 'roles.yml'
  confine :exists => default_target
end
