Puppet::Type.newtype(:elasticsearch_user) do
  desc 'Type to model Elasticsearch users.'

  feature :manages_plaintext_passwords,
          'The provider can control the password in plaintext form.'

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

  newparam(
    :password,
    :required_features => :manages_plaintext_passwords
  ) do
    desc 'Plaintext password for user.'

    validate do |value|
      if value.length < 6
        raise ArgumentError, 'Password must be at least 6 characters long'
      end
    end

    # rubocop:disable Style/PredicateName
    def is_to_s(_currentvalue)
      '[old password hash redacted]'
    end
    # rubocop:enable Style/PredicateName

    def should_to_s(_newvalue)
      '[new password hash redacted]'
    end
  end

  def refresh
    if @parameters[:ensure]
      provider.passwd
    else
      debug 'skipping password set'
    end
  end
end
