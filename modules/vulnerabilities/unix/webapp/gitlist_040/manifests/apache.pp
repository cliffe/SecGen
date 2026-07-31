class gitlist_040::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/gitlist'

  class { '::apache':
    default_vhost => false,
    default_mods => ['rewrite'], # php5 via separate module
    overwrite_ports => false,
    mpm_module => 'prefork'
  }

  ::apache::vhost { 'www-gitlist':
    port     => $port,
    docroot  => $docroot,
    priority => '05',
    notify   => Tidy['gl remove default site']
  }

  ensure_resource('tidy','gl remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})
  #
  #
  # exec { 'disable php7':
  #   command => '/usr/sbin/a2dismod php7.0',
  # }
}
