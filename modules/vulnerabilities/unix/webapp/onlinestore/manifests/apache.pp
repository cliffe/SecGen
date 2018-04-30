class onlinestore::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/onlinestore'

  package { ['php5', 'mysql-client','php5-mysql']:
    ensure => installed,
  }

  class { '::apache':
    default_vhost => false,
    default_mods => 'php',
    overwrite_ports => false,
  }

  ::apache::vhost { 'onlinestore':
    port    => $port,
    docroot => $docroot,
  }
}