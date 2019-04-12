require 'puppet/provider/elastic_user_roles'

Puppet::Type.type(:elasticsearch_user_roles).provide(
  :shield,
  :parent => Puppet::Provider::ElasticUserRoles
) do
  desc 'Provider for Shield user roles (parsed file.)'

  shield_config 'users_roles'
  confine :exists => default_target
end
