# Class: glpi_php_injection::maria
# maria db install and configuration
#
class glpi_php_injection::maria {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  $db_name = 'glpidb'
  $db_user = 'user'
  # maybe change this soon?
  $db_pass = 'demo'

  file { '/tmp/mysql_secure.sh':
    ensure => file,
    source => 'puppet:///modules/glpi_php_injection/mysql_secure.sh',
  }
  -> exec { 'chmod-mysql-secure':
    cwd     => '/tmp',
    command => 'chmod +x mysql_secure.sh',
  }
  # we need provider here. puppet doesnt discover platform...?
  -> exec { 'mysql-secure-install':
    provider => 'shell',
    cwd      => '/tmp',
    command  => "./mysql_secure.sh ${db_pass}",
  }

  mysql::db {  'glpidb':
    user     => $db_user,
    password => $db_pass,
    dbname   => $db_name,
    host     => 'localhost',
    grant    => ['ALL'],
  }

  # glpi provides a cli installer - we can utilise this to set it up.
  # See: https://glpi-install.readthedocs.io/en/latest/command-line.html#cdline-install
  -> exec { 'glpi-cli-install':
    cwd       => '/var/www/html/glpi/bin/',
    command   => "php console db:install -f -H localhost -P ${port} -d ${db_name} -u ${db_user} -p ${db_pass}",
    logoutput => true,
  }
}
