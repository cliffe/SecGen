class drupal_850::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/drupal-8.5.0'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_resource('tidy','gl remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})
  
  class { '::apache':
    default_vhost => false,
  } ->
  
  ::apache::vhost { 'www-drupal':
    port    => $port,
    docroot => $docroot,
  } ->

  exec { 'restart-apache-drupal':
    command => 'service apache2 restart; sleep 3;',
    logoutput => true
  }
}
