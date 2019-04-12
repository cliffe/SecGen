Puppet::Type.newtype(:elasticsearch_user_file) do
  desc 'Type to model Elasticsearch users.'

  feature :manages_encrypted_passwords,
          'The provider can control the password hash without a need
          to explicitly refresh.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'User name.'
  end

  newparam(:configdir) do
    desc 'Path to the elasticsearch configuration directory (ES_PATH_CONF).'

    validate do |value|
      raise Puppet::Error, 'path expected' if value.nil?
    end
  end

  newproperty(
    :hashed_password,
    :required_features => :manages_encrypted_passwords
  ) do
    desc 'Hashed password for user.'

    newvalues(/^[$]2a[$].{56}$/)
  end
end
