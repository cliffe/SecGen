require 'puppet/provider/elastic_user_command'

Puppet::Type.type(:elasticsearch_user).provide(
  :esusers,
  :parent => Puppet::Provider::ElasticUserCommand
) do
  desc 'Provider for Shield file (esusers) user resources.'

  has_feature :manages_plaintext_passwords

  mk_resource_methods

  commands :users_cli => "#{homedir}/bin/shield/esusers"
  commands :es => "#{homedir}/bin/elasticsearch"
end
