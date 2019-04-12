require 'puppet/provider/elastic_user_roles'

Puppet::Type.type(:elasticsearch_user_roles).provide(
  :xpack,
  :parent => Puppet::Provider::ElasticUserRoles
) do
  desc 'Provider for X-Pack user roles (parsed file.)'

  xpack_config 'users_roles'
  confine :exists => default_target
end
