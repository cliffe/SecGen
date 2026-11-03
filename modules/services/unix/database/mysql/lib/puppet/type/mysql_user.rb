# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
  @doc = <<-PUPPET
    @summary
      Manage a MySQL user. This includes management of users password as well as privileges.

    @api private
    PUPPET

  ensurable

  autorequire(:file) { '/root/.my.cnf' }
  autorequire(:class) { 'mysql::server' }

  newparam(:name, namevar: true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # http://dev.mysql.com/doc/refman/5.5/en/identifiers.html
      # If at least one special char is used, string must be quoted
      # http://stackoverflow.com/questions/8055727/negating-a-backreference-in-regular-expressions/8057827#8057827
      mysql_version = Facter.value(:mysql_version)
      # rubocop:disable Lint/AssignmentInCondition
      # rubocop:disable Lint/UselessAssignment
      if matches = %r{^(['`"])((?:(?!\1).)*)\1@([\w%\.:\-/]+)$}.match(value)
        user_part = matches[2]
        host_part = matches[3]
      elsif matches = %r{^([0-9a-zA-Z$_]*)@([\w%\.:\-/]+)$}.match(value)
        user_part = matches[1]
        host_part = matches[2]
      elsif matches = %r{^((?!['`"]).*[^0-9a-zA-Z$_].*)@(.+)$}.match(value)
        user_part = matches[1]
        host_part = matches[2]
      else
        raise ArgumentError, _('Invalid database user %{user}.') % { user: value }
      end
      # rubocop:enable Lint/AssignmentInCondition
      # rubocop:enable Lint/UselessAssignment
      unless mysql_version.nil?
        raise(ArgumentError, _('MySQL usernames are limited to a maximum of 16 characters.')) if Puppet::Util::Package.versioncmp(mysql_version, '5.7.8') < 0 && user_part.size > 16
        raise(ArgumentError, _('MySQL usernames are limited to a maximum of 32 characters.')) if Puppet::Util::Package.versioncmp(mysql_version, '10.0.0') < 0 && user_part.size > 32
        raise(ArgumentError, _('MySQL usernames are limited to a maximum of 80 characters.')) if Puppet::Util::Package.versioncmp(mysql_version, '10.0.0') > 0 && user_part.size > 80
      end
    end

    munge do |value|
      matches = %r{^((['`"]?).*\2)@(.+)$}.match(value)
      "#{matches[1]}@#{matches[3].downcase}"
    end
  end

  newproperty(:password_hash) do
    desc 'The password hash of the user. Use mysql_password() for creating such a hash.'
    newvalue(%r{\w*})

    def change_to_s(currentvalue, _newvalue)
      (currentvalue == :absent) ? 'created password' : 'changed password'
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

  newproperty(:plugin) do
    desc 'The authentication plugin of the user.'
    newvalue(%r{\w+})
  end

  newproperty(:max_user_connections) do
    desc 'Max concurrent connections for the user. 0 means no (or global) limit.'
    newvalue(%r{\d+})
  end

  newproperty(:max_connections_per_hour) do
    desc 'Max connections per hour for the user. 0 means no (or global) limit.'
    newvalue(%r{\d+})
  end

  newproperty(:max_queries_per_hour) do
    desc 'Max queries per hour for the user. 0 means no (or global) limit.'
    newvalue(%r{\d+})
  end

  newproperty(:max_updates_per_hour) do
    desc 'Max updates per hour for the user. 0 means no (or global) limit.'
    newvalue(%r{\d+})
  end

  newproperty(:tls_options, array_matching: :all) do
    desc 'Options to that set the TLS-related REQUIRE attributes for the user.'
    validate do |value|
      value = [value] unless value.is_a?(Array)
      if value.include?('NONE') || value.include?('SSL') || value.include?('X509')
        if value.length > 1
          raise(ArgumentError, _('`tls_options` `property`: The values NONE, SSL and X509 cannot be used with other options, you may only pick one of them.'))
        end
      else
        value.each do |opt|
          o = opt.match(%r{^(CIPHER|ISSUER|SUBJECT)}i)
          raise(ArgumentError, _('Invalid tls option %{option}.') % { option: o }) unless o
        end
      end
    end
    def insync?(is)
      # The current value may be nil and we don't
      # want to call sort on it so make sure we have arrays
      if is.is_a?(Array) && @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end
