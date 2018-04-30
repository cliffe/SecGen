class gitlist_040::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/gitlist'

  package { 'php5':
    ensure => installed,
  }
  #
  # include ::apache::mod::rewrite
  # include ::apache::mod::php

  class { '::apache':
    default_vhost => false,
    default_mods => ['rewrite', 'php'],
    overwrite_ports => false,
  }

  ::apache::vhost { 'www-gitlist':
    port    => $port,
    docroot => $docroot,
  }
}