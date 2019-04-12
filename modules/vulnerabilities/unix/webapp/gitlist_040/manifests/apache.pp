class gitlist_040::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/gitlist'

  class { '::apache':
    default_vhost => false,
    default_mods => ['rewrite', 'php'],
    overwrite_ports => false,
    mpm_module => 'prefork'
  }

  ::apache::vhost { 'www-gitlist':
    port    => $port,
    docroot => $docroot,
  }
}