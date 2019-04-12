require 'puppet/provider/elastic_parsedfile'

Puppet::Type.type(:elasticsearch_user_file).provide(
  :shield,
  :parent => Puppet::Provider::ElasticParsedFile
) do
  desc 'Provider for Shield esusers using plain files.'

  shield_config 'users'
  confine :exists => default_target

  has_feature :manages_encrypted_passwords

  text_line :comment,
            :match => /^\s*#/

  record_line :shield,
              :fields => %w[name hashed_password],
              :separator => ':',
              :joiner => ':'

  def self.valid_attr?(klass, attr_name)
    if klass.respond_to? :parameters
      klass.parameters.include?(attr_name)
    else
      true
    end
  end
end
