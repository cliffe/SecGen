# Exposes the required PostgreSQL service to the network and adds a superuser
# with a weak password, so COPY ... FROM PROGRAM can be driven over the wire to
# run OS commands as the postgres account.
#
# The postgresql service module (a <requires> dependency) owns pg_hba.conf and
# the base config; this class layers on top of it from a later catalog: a
# conf.d drop-in read last reopens listen_addresses, and a file_line appends a
# network rule for the superuser (first-match-wins leaves the base rules intact).
class postgresql_copy_rce::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username    = $secgen_parameters['username'][0]
  $password    = $secgen_parameters['password'][0]
  $auth_method = $secgen_parameters['auth_method'][0]

  $conf_dir  = '/etc/postgresql/15/main'
  $setup_sql = '/var/lib/postgresql/secgen_copy_rce_setup.sql'

  # Read after the base config (zz_ sorts last in conf.d) so it wins: bind every
  # interface, making the superuser reachable from the network.
  file { "${conf_dir}/conf.d/zz_secgen_copy_rce.conf":
    ensure  => file,
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0644',
    content => template('postgresql_copy_rce/zz_secgen_copy_rce.conf.erb'),
    notify  => Exec['secgen_copy_rce_restart'],
  }

  # Allow the superuser in from any address. The base rules only cover the
  # service's own role and loopback, so this account is not matched earlier.
  file_line { 'secgen_copy_rce_hba_v4':
    path   => "${conf_dir}/pg_hba.conf",
    line   => "host    all             ${username}      0.0.0.0/0               ${auth_method}",
    notify => Exec['secgen_copy_rce_restart'],
  }
  file_line { 'secgen_copy_rce_hba_v6':
    path   => "${conf_dir}/pg_hba.conf",
    line   => "host    all             ${username}      ::/0                    ${auth_method}",
    notify => Exec['secgen_copy_rce_restart'],
  }

  # A listen_addresses change needs a full restart; a reload is not enough.
  exec { 'secgen_copy_rce_restart':
    command     => '/usr/bin/systemctl restart postgresql@15-main',
    refreshonly => true,
  }

  exec { 'secgen_copy_rce_wait':
    command   => '/usr/bin/pg_isready -q',
    tries     => 15,
    try_sleep => 2,
    require   => Exec['secgen_copy_rce_restart'],
  }

  # The SQL holds the password, so it is removed as soon as psql has run it.
  file { $setup_sql:
    ensure    => file,
    owner     => 'postgres',
    group     => 'postgres',
    mode      => '0600',
    content   => template('postgresql_copy_rce/setup.sql.erb'),
    show_diff => false,
    require   => Exec['secgen_copy_rce_wait'],
  }

  exec { 'secgen_copy_rce_role':
    command  => "/usr/sbin/runuser -u postgres -- /usr/bin/psql -v ON_ERROR_STOP=1 -q -f ${setup_sql}; rc=\$?; rm -f ${setup_sql}; exit \$rc",
    provider => shell,
    require  => File[$setup_sql],
  }
}
