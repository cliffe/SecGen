# Opens PostgreSQL to the network and adds a weakly-protected remote superuser
# account, so the password hashes in pg_shadow/pg_authid can be dumped over the wire.
#
# Design notes:
#  - The role is created with an md5-encrypted password (SET password_encryption =
#    'md5' for the session) and the pg_hba.conf line uses md5. md5 is universally
#    supported by the Metasploit postgres client and gives a trivially crackable
#    hash, which is the point of the lesson. The stored hash format must match the
#    pg_hba method, so both are md5.
#  - PostgreSQL 15 pg_hba.conf has no include directive (that arrived in 16), so the
#    remote-access line is inserted into the service module's file with sed rather
#    than a drop-in. It goes near the top so it matches before the service's loopback
#    'all' lines (which use scram-sha-256 and would reject an md5-stored password).
#  - SecGen provisions each module as a separate puppet run (one vm.provision "puppet"
#    block per module), and places a module's `requires` dependencies before it, so by
#    the time this runs the postgresql service module has already installed the server,
#    created its role/database and started the cluster. The service's resources are in a
#    different catalog, so this module must not reference them (Class['postgresql::install'],
#    Exec['create postgresql role and database'], ...): ordering is handled by SecGen, and
#    this module orders only its own resources.
class postgres_hashdump::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $username = $secgen_parameters['username'][0]
  $password = $secgen_parameters['password'][0]

  $conf_dir   = '/etc/postgresql/15/main'
  $hba_file   = "${conf_dir}/pg_hba.conf"
  $setup_sql  = '/var/lib/postgresql/secgen_hashdump_setup.sql'

  # Override the service's listen_addresses. Debian's postgresql.conf reads conf.d
  # last and the last setting wins, so a 'zz_' drop-in beats the service's
  # conf.d/secgen.conf (which pins listen_addresses = 'localhost').
  file { "${conf_dir}/conf.d/zz_secgen_remote.conf":
    ensure  => file,
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0644',
    content => "listen_addresses = '*'\n",
    notify  => Exec['secgen_pg_restart_remote'],
  }

  # The SQL holds the password, so it is removed as soon as psql has run it. The
  # service module's earlier puppet run has already created its role and database.
  file { $setup_sql:
    ensure    => file,
    owner     => 'postgres',
    group     => 'postgres',
    mode      => '0600',
    content   => template('postgres_hashdump/superuser.sql.erb'),
    show_diff => false,
  }

  exec { 'secgen_pg_create_superuser':
    command  => "/usr/sbin/runuser -u postgres -- /usr/bin/psql -p 5432 -v ON_ERROR_STOP=1 -q -f ${setup_sql}; rc=\$?; rm -f ${setup_sql}; exit \$rc",
    provider => shell,
    require  => File[$setup_sql],
    notify   => Exec['secgen_pg_restart_remote'],
  }

  # Allow the superuser to authenticate (md5) from any host. Inserted after line 1
  # (the header comment), ahead of the service's loopback scram-sha-256 'all' lines,
  # so first-match-wins picks md5 for this account on every interface.
  $hba_line = "host    all    ${username}    0.0.0.0/0    md5"
  exec { 'secgen_pg_remote_hba':
    command  => "sed -i '1a ${hba_line}' ${hba_file}",
    unless   => "grep -qE '^host[[:space:]]+all[[:space:]]+${username}[[:space:]]+0\\.0\\.0\\.0/0[[:space:]]+md5' ${hba_file}",
    path     => ['/bin', '/usr/bin'],
    provider => shell,
    require  => Exec['secgen_pg_create_superuser'],
    notify   => Exec['secgen_pg_restart_remote'],
  }

  # Apply listen_addresses and pg_hba changes, then wait until the cluster is back.
  exec { 'secgen_pg_restart_remote':
    command     => '/usr/bin/systemctl restart postgresql@15-main && /usr/bin/pg_isready -q -t 30',
    provider    => shell,
    refreshonly => true,
  }
}
