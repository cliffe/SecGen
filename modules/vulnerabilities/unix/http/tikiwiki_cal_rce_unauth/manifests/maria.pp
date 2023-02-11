# Class: tikiwiki_cal_rce_unauth::maria
# Setup mariadb context
#
class tikiwiki_cal_rce_unauth::maria {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  $db_name = 'tikiwiki'
  $db_user = 'user'
  # maybe change this soon?
  $db_pass = 'demo'

  # we need to run through the mysql_secure_install command
  file { '/tmp/mysql_secure.sh':
    ensure => file,
    source => 'puppet:///modules/tikiwiki_cal_rce_unauth/mysql_secure.sh',
  }
  -> exec { 'chmod-mysql-secure':
    cwd     => '/tmp',
    command => 'chmod +x mysql_secure.sh',
  }
  -> exec { 'mysql-secure-install':
    provider => 'shell',
    cwd      => '/tmp',
    command  => "./mysql_secure.sh ${db_pass}",
  }

  mysql::db {  $db_name:
    user     => $db_user,
    password => $db_pass,
    dbname   => $db_name,
    host     => 'localhost',
    grant    => ['ALL'],
  }
}
