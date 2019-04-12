require 'puppet/provider/elastic_parsedfile'

Puppet::Type.type(:elasticsearch_user_file).provide(
  :oss_xpack,
  :parent => Puppet::Provider::ElasticParsedFile
) do
  desc 'Provider for OSS X-Pack users using plain files.'

  oss_xpack_config 'users'
  confine :exists => default_target

  has_feature :manages_encrypted_passwords

  text_line :comment,
            :match => /^\s*#/

  record_line :oss_xpack,
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
