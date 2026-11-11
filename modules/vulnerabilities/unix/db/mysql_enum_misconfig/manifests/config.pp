# Seeds the required MySQL/MariaDB service with CIS-style weaknesses:
# remote exposure (bind-address 0.0.0.0), a weak remotely-reachable account,
# an anonymous account with a blank password, grants on a wildcard host, and
# over-broad privileges (global SELECT, FILE and GRANT) on the non-admin account.
class mysql_enum_misconfig::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $account_username  = $secgen_parameters['account_username'][0]
  $account_password  = $secgen_parameters['account_password'][0]
  $database_name     = $secgen_parameters['database_name'][0]

  Exec {
    path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }

  # Expose the server on all interfaces so the audit reaches it over the network.
  # The required mysql service module provisions (and starts MariaDB) before this
  # module runs, and its my.cnf ends with !includedir /etc/mysql/conf.d, so a file
  # here is read after the default bind-address and overrides it. Each SecGen module
  # is a separate Puppet catalog, so the service module's resources aren't visible
  # here — restart the service with an exec rather than a cross-catalog notify.
  file { '/etc/mysql/conf.d/99-secgen-remote.cnf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "[mysqld]\nbind-address = 0.0.0.0\nskip-networking = 0\n",
  }
  ~> exec { 'secgen-mysql-remote-restart':
    command     => 'systemctl restart mariadb',
    refreshonly => true,
  }

  # Seed the accounts and grants. Puppet runs as root and authenticates to MariaDB
  # over the local socket, so no password is needed here. The accounts and their
  # over-broad privileges are the weaknesses mysql_enum reports; the non-admin
  # account's global SELECT is also what lets the audit read mysql.user remotely.
  $seed_sql = @("SQL")
    CREATE DATABASE IF NOT EXISTS ${database_name};
    CREATE USER IF NOT EXISTS '${account_username}'@'%' IDENTIFIED BY '${account_password}';
    GRANT ALL PRIVILEGES ON ${database_name}.* TO '${account_username}'@'%';
    GRANT SELECT ON *.* TO '${account_username}'@'%' WITH GRANT OPTION;
    GRANT FILE ON *.* TO '${account_username}'@'%';
    CREATE USER IF NOT EXISTS ''@'%' IDENTIFIED BY '';
    GRANT SELECT ON ${database_name}.* TO ''@'%';
    FLUSH PRIVILEGES;
    | SQL

  exec { 'secgen-mysql-seed-weaknesses':
    command  => "mysql <<'SECGEN_EOSQL'\n${seed_sql}\nSECGEN_EOSQL\n",
    provider => shell,
    unless   => "test \"$(mysql -N -B -e \"SELECT COUNT(*) FROM mysql.user WHERE user='${account_username}' AND host='%'\")\" = 1",
    require  => [File['/etc/mysql/conf.d/99-secgen-remote.cnf'], Exec['secgen-mysql-remote-restart']],
  }
}
