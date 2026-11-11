# Writes the server settings and pg_hba.conf, then creates the database and login role.
class postgresql::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port             = $secgen_parameters['port'][0]
  $database_name    = $secgen_parameters['database_name'][0]
  $username         = $secgen_parameters['username'][0]
  $password         = $secgen_parameters['password'][0]
  $listen_addresses = $secgen_parameters['listen_addresses'][0]
  $auth_method      = $secgen_parameters['auth_method'][0]

  $conf_dir = '/etc/postgresql/15/main'
  $setup_sql = '/var/lib/postgresql/secgen_setup.sql'

  # Debian's postgresql.conf includes conf.d/*.conf
  file { "${conf_dir}/conf.d/secgen.conf":
    ensure  => file,
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0644',
    content => template('postgresql/secgen.conf.erb'),
    require => Class['postgresql::install'],
    notify  => Exec['restart postgresql cluster'],
  }

  file { "${conf_dir}/pg_hba.conf":
    ensure  => file,
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0640',
    content => template('postgresql/pg_hba.conf.erb'),
    require => Class['postgresql::install'],
    notify  => Exec['restart postgresql cluster'],
  }

  exec { 'restart postgresql cluster':
    command     => '/usr/bin/systemctl restart postgresql@15-main',
    refreshonly => true,
  }

  exec { 'wait for postgresql':
    command   => "/usr/bin/pg_isready -q -p ${port}",
    tries     => 15,
    try_sleep => 2,
    require   => Exec['restart postgresql cluster'],
  }

  # The SQL holds the password, so it is removed as soon as psql has run it
  file { $setup_sql:
    ensure    => file,
    owner     => 'postgres',
    group     => 'postgres',
    mode      => '0600',
    content   => template('postgresql/setup.sql.erb'),
    show_diff => false,
    require   => Exec['wait for postgresql'],
  }

  exec { 'create postgresql role and database':
    command  => "/usr/sbin/runuser -u postgres -- /usr/bin/psql -p ${port} -v ON_ERROR_STOP=1 -q -f ${setup_sql}; rc=\$?; rm -f ${setup_sql}; exit \$rc",
    provider => shell,
    require  => File[$setup_sql],
  }
}
