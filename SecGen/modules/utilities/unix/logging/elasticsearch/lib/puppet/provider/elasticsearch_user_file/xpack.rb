require 'puppet/provider/elastic_parsedfile'

Puppet::Type.type(:elasticsearch_user_file).provide(
  :xpack,
  :parent => Puppet::Provider::ElasticParsedFile
) do
  desc 'Provider for X-Pack esusers using plain files.'

  xpack_config 'users'
  confine :exists => default_target

  has_feature :manages_encrypted_passwords

  text_line :comment,
            :match => /^\s*#/

  record_line :xpack,
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
