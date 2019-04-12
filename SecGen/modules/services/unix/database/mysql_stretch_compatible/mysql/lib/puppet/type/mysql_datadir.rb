Puppet::Type.newtype(:mysql_datadir) do
  @doc = <<-PUPPET
    @summary
      Manage MySQL datadirs with mysql_install_db OR mysqld (5.7.6 and above).

    @api private
    PUPPET

  ensurable

  autorequire(:package) { 'mysql-server' }

  newparam(:datadir, namevar: true) do
    desc 'The datadir name'
  end

  newparam(:basedir) do
    desc 'The basedir name, default /usr.'
    newvalues(%r{^/})
  end

  newparam(:user) do
    desc 'The user for the directory default mysql (name, not uid).'
  end

  newparam(:defaults_extra_file) do
    desc 'MySQL defaults-extra-file with absolute path (*.cnf).'
    newvalues(%r{^/.*\.cnf$})
  end

  newparam(:insecure, boolean: true) do
    desc 'Insecure initialization (needed for 5.7.6++).'
  end

  newparam(:log_error) do
    desc 'The path to the mysqld error log file (used with the --log-error option)'
    newvalues(%r{^/})
  end
end
