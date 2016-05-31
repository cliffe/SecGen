#
class mysql::server::root_password {

  $options = $mysql::server::options
  $secret_file = $mysql::server::install_secret_file

  # New installations of MySQL will configure a default random password for the root user
  # with an expiration. No actions can be performed until this password is changed. The
  # below exec will remove this default password. If the user has supplied a root
  # password it will be set further down with the mysql_user resource.
  $rm_pass_cmd = join([
    "mysqladmin -u root --password=\$(grep -o '[^ ]\\+\$' ${secret_file}) password ''",
    "rm -f ${secret_file}"
  ], ' && ')
  exec { 'remove install pass':
    command => $rm_pass_cmd,
    onlyif  => "test -f ${secret_file}",
    path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  }

  # manage root password if it is set
  if $mysql::server::create_root_user == true and $mysql::server::root_password != 'UNSET' {
    mysql_user { 'root@localhost':
      ensure        => present,
      password_hash => mysql_password($mysql::server::root_password),
      require       => Exec['remove install pass']
    }
  }

  if $mysql::server::create_root_my_cnf == true and $mysql::server::root_password != 'UNSET' {
    file { "${::root_home}/.my.cnf":
      content => template('mysql/my.cnf.pass.erb'),
      owner   => 'root',
      mode    => '0600',
    }

    # show_diff was added with puppet 3.0
    if versioncmp($::puppetversion, '3.0') >= 0 {
      File["${::root_home}/.my.cnf"] { show_diff => false }
    }
    if $mysql::server::create_root_user == true {
      Mysql_user['root@localhost'] -> File["${::root_home}/.my.cnf"]
    }
  }

}
