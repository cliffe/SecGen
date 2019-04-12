class commando::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $db_password = $secgen_parameters['db_password'][0]

  # essential packages for commando to function
  package { ['php', 'php-mysqli', 'php-gd', 'libapache2-mod-php','mysql-server']:
    ensure => installed,
  }

  class { '::apache':
    default_vhost => false,
    overwrite_ports => false,
    mpm_module => 'prefork'
  } ->

  apache::vhost { 'commando':
    port    => $port,
    docroot => '/var/www/commando',
  } ->

  # enabling of the php7.0 module so functions on app work
  exec { 'a2enmod php7.0':
    command  => "/usr/sbin/a2enmod php7.0",
    require => Class['::apache']
  }

# creating a required user at localhost
mysql_user{ 'commando_user@localhost':
  ensure        => present,
  password_hash => mysql_password($db_password)
}
}
