# Class: glpi_php_injection::apache
# Apache virtual host for GLPI.
#
class glpi_php_injection::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  # GLPI 9.5.x's webroot is the extracted glpi/ directory itself (no public/
  # subdir, unlike GLPI 10) - a vhost on /var/www/html/ would only serve a
  # directory listing, not the app.
  $docroot = '/var/www/html/glpi/'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  class { '::apache':
    default_vhost   => false,
  }

  # Activate the PHP 7.4 Apache module installed by install.pp so the vhost
  # does not fall back to Debian's stock 8.2 (GLPI 9.5.8 has PHP 8.x
  # incompatibilities at runtime; see install.pp for why 7.4 is used here).
  exec { 'enable-apache-php7.4':
    command => 'a2enmod php7.4',
    require => Package['libapache2-mod-php7.4'],
    before  => Service['httpd'],
  }

  ::apache::vhost { 'glpi':
    priority => '05', # ahead of the apache module's own vhost on the same port
    port       => $port,
    docroot    => $docroot,
    options    => ['FollowSymLinks'],
    override   => ['All'],
    error_log  => true,
    access_log => true,
  }

  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => 'absent',
  }
  -> exec { 'service-restart-apache2':
    command   => 'service apache2 restart',
    logoutput => true,
  }
}
