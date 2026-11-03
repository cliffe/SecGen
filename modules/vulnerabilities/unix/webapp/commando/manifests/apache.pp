class commando::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $db_password = $secgen_parameters['db_password'][0]

  # essential packages for commando to function
  package { ['php', 'php-gd', 'libapache2-mod-php']:
    ensure => installed,
  }

  class { '::apache':
    default_vhost => false,
    overwrite_ports => false,
    mpm_module => 'prefork'
  } ->

  apache::vhost { 'commando':
    priority => '05', # ahead of the apache module's own vhost on the same port
    port    => $port,
    docroot => '/var/www/commando',
  } ->

  # enabling of the php5.6 module so functions on app work
  exec { 'a2enmod php5.6':
    command  => "/usr/sbin/a2enmod php5.6",
    require => Class['::apache']
  }

  # creating a required user at localhost
  mysql_user{ 'commando_user@localhost':
    ensure        => present,
    password_hash => mysql_password($db_password)
  }

  ensure_resource('tidy','commando remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})

}
