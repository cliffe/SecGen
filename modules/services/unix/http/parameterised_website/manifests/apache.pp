class parameterised_website::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  class { '::apache':
    default_vhost => false,
    overwrite_ports => false,
  }

  apache::vhost { 'vhost.test.com':
    port    => $port,
    docroot => '/var/www/parameterised_website',
  }
}