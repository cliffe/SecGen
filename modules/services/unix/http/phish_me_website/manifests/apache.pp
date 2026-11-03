class phish_me_website::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  class { '::apache':
    default_vhost => false,
    mpm_module => 'prefork',
  }

  # Apache PHP handler for the PHP under Action/ (PHP core comes from php82_patched)
  ensure_packages(['libapache2-mod-php'])

  apache::vhost { 'accountingnow.com':
    priority => '05', # ahead of the apache module's own vhost on the same port
    port    => $port,
    docroot => '/var/www/accountingnow/',
    notify => Tidy['pws remove default site'],
  }

  ensure_resource('tidy','pws remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})
}
