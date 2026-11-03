Puppet::Type.newtype(:mysql_plugin) do
  @doc = <<-PUPPET
    @summary
      Manage MySQL plugins.

    @example
      mysql_plugin { 'some_plugin':
        soname => 'some_pluginlib.so',
      }

  PUPPET

  ensurable

  autorequire(:file) { '/root/.my.cnf' }

  newparam(:name, namevar: true) do
    desc 'The name of the MySQL plugin to manage.'
  end

  newproperty(:soname) do
    desc 'The name of the library'
    newvalue(%r{^\w+\.\w+$})
  end
end
