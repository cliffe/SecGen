# Configure the MySQL FILE-privilege misconfiguration.
#
# The required mysql service module already declares mysql::server, so rather
# than redeclaring it this class drops an override into the include directory
# that module's my.cnf reads (!includedir /etc/mysql/conf.d on Debian). The
# override empties secure_file_priv (read anywhere) and binds the server to all
# interfaces so the FILE-privileged account is reachable from the network. The
# account, its database and the planted flag are created with the mysql module's
# own defined types (available because it is a <requires> dependency).
class mysql_file_priv_enum::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username          = $secgen_parameters['username'][0]
  $password          = $secgen_parameters['password'][0]
  $enum_database     = $secgen_parameters['enum_database'][0]
  $storage_directory = $secgen_parameters['storage_directory'][0]
  $leaked_filenames  = $secgen_parameters['leaked_filenames']
  $strings_to_leak   = $secgen_parameters['strings_to_leak']

  # Empty secure_file_priv removes the filesystem restriction on LOAD_FILE /
  # LOAD DATA INFILE; bind-address 0.0.0.0 exposes the account remotely.
  file { '/etc/mysql/conf.d/secgen_file_priv.cnf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "[mysqld]\nsecure_file_priv =\nbind-address = 0.0.0.0\n",
  }
  # The service was started by the mysql module (an earlier, separate catalog),
  # so restart it here to apply the override. refreshonly keeps it idempotent.
  ~> exec { 'secgen-restart-mariadb-file-priv':
    command     => 'systemctl restart mariadb 2>/dev/null || systemctl restart mysql 2>/dev/null || systemctl restart mysqld',
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    refreshonly => true,
  }

  # A database the account owns, so mysql_file_enum can create its staging table.
  # Ordered after the restart so the account is created against the running
  # server, not mid-restart (systemctl restart blocks until the unit is back up).
  Exec['secgen-restart-mariadb-file-priv']
  -> mysql::db { $enum_database:
    user     => $username,
    password => $password,
    host     => '%',
    grant    => ['ALL'],
  }

  # The global FILE privilege is what makes arbitrary file reads possible.
  mysql_grant { "${username}@%/*.*":
    ensure     => 'present',
    user       => "${username}@%",
    table      => '*.*',
    privileges => ['FILE'],
    require    => Mysql::Db[$enum_database],
  }

  # Plant the flag at a server-readable path. mode 0644 lets the database
  # process (the mysql user) read it; leak_files creates the directory.
  ::secgen_functions::leak_files { 'mysql_file_priv_enum_flag':
    storage_directory => $storage_directory,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => 'mysql_file_priv_enum',
    owner             => 'root',
    group             => 'root',
    mode              => '0644',
  }
}
