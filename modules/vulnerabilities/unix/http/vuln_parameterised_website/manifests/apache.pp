class vuln_parameterised_website::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  package { ['php', 'php-gd', 'libapache2-mod-php', 'php-mysql']:
    ensure => installed,
  }

  class { '::apache':
    default_vhost => false,
    overwrite_ports => false,
    mpm_module => 'prefork',
  }


  apache::vhost { 'parameterised.website':
    priority => '05', # ahead of the apache module's own vhost on the same port
    port    => $port,
    docroot => '/var/www/vuln_parameterised_website',
    notify => Tidy['pws remove default site'],
  }

  ensure_resource('tidy','pws remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})
}