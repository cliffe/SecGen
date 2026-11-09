# Opens MySQL/MariaDB to the network and adds a weakly-protected remote DBA
# account, so its password hashes can be dumped over the wire.
class mysql_remote_hashdump::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $username = $secgen_parameters['username'][0]
  $password = $secgen_parameters['password'][0]

  # The required mysql service declares ::mysql::server, which writes my.cnf with
  # bind-address = 127.0.0.1. A drop-in loaded after it (via !includedir, read
  # last) flips the server to listen on every interface.
  file { '/etc/mysql/conf.d/zz_secgen_remote_access.cnf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "[mysqld]\nbind-address = 0.0.0.0\n",
  }

  # Remote administrative account with a weak password, stored as a
  # mysql_native_password hash so there is a real hash to dump.
  mysql_user { "${username}@%":
    ensure        => present,
    password_hash => mysql_password($password),
    require       => File['/etc/mysql/conf.d/zz_secgen_remote_access.cnf'],
  }

  # Full privileges (reads mysql.user, among everything else) from any host.
  mysql_grant { "${username}@%/*.*":
    ensure     => present,
    user       => "${username}@%",
    table      => '*.*',
    privileges => ['ALL'],
    require    => Mysql_user["${username}@%"],
  }

  # Apply the new bind-address. Restart last so the account changes above have
  # already gone in over the local socket before the brief service bounce.
  exec { 'secgen_mariadb_restart_remote':
    command     => 'systemctl restart mariadb || systemctl restart mysql',
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    refreshonly => true,
    subscribe   => File['/etc/mysql/conf.d/zz_secgen_remote_access.cnf'],
    require      => Mysql_grant["${username}@%/*.*"],
  }
}
