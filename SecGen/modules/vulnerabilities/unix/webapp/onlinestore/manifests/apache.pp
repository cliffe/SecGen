class onlinestore::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/onlinestore'

  class { '::apache':
    default_vhost   => false,
    overwrite_ports => false,
    mpm_module      => 'prefork',
  }

  ::apache::vhost { 'onlinestore':
    port    => $port,
    docroot => $docroot,
  }

  case $operatingsystemrelease {
    /^9.*/: { # do 9.x stretch stuff
      exec { 'a2enmod php5.6':
        command => '/usr/sbin/a2enmod php5.6',
        require => Class['::apache']
      }
    }
    /^7.*/: { #do 7.x wheezy stuff
      exec { 'a2enmod php5':
        command => '/usr/sbin/a2enmod php5',
        require => Class['::apache']
      }
    }
  }
}