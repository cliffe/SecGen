require 'puppet/provider/elastic_user_command'

Puppet::Type.type(:elasticsearch_user).provide(
  :users,
  :parent => Puppet::Provider::ElasticUserCommand
) do
  desc 'Provider for X-Pack file (users) user resources.'
  confine :false => (Puppet::FileSystem.exist? "#{homedir}/bin/elasticsearch-users")

  has_feature :manages_plaintext_passwords

  mk_resource_methods

  commands :users_cli => "#{homedir}/bin/x-pack/users"
  commands :es => "#{homedir}/bin/elasticsearch"
end
