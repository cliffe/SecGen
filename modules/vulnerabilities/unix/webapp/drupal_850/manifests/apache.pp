class drupal_850::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/drupal-8.5.0'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Self-contained Apache (plain apt + config, no puppetlabs-apache) so the
  # module does not depend on the stretch-era apache_*_compatible service. .php
  # is handed to php7_patched's php-fpm (127.0.0.1:9000) over FastCGI, and
  # Drupal's .htaccess rewrites are enabled for clean URLs.
  ensure_packages(['apache2'])

  exec { 'drupal-apache-mods':
    command => 'a2enmod proxy proxy_fcgi rewrite',
    unless  => 'test -e /etc/apache2/mods-enabled/proxy_fcgi.load',
    require => Package['apache2'],
  }

  file { '/etc/apache2/ports.conf':
    ensure  => file,
    content => "Listen ${port}\n",
    require => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/drupal.conf':
    ensure  => file,
    content => "<VirtualHost *:${port}>\n  DocumentRoot ${docroot}\n  DirectoryIndex index.php\n  <Directory ${docroot}>\n    AllowOverride All\n    Require all granted\n  </Directory>\n  <FilesMatch \\.php$>\n    SetHandler \"proxy:fcgi://127.0.0.1:9000\"\n  </FilesMatch>\n</VirtualHost>\n",
    require => Package['apache2'],
  }

  exec { 'drupal-apache-sites':
    command => 'a2dissite 000-default; a2ensite drupal',
    require => [File['/etc/apache2/sites-available/drupal.conf'], Exec['drupal-apache-mods']],
  }
  -> exec { 'restart-apache-drupal':
    command   => 'systemctl restart apache2; sleep 3;',
    require   => [File['/etc/apache2/ports.conf'], Exec['drupal-apache-mods']],
    logoutput => true,
  }
  # Drupal's first uncached request builds caches and aggregated assets and can
  # take longer than a test's HTTP timeout; warm it during provisioning.
  -> exec { 'warm-drupal-cache':
    command  => "for i in 1 2 3 4 5; do curl -s -o /dev/null --max-time 120 http://127.0.0.1:${port}/ && break; sleep 5; done; true",
    provider => shell,
    timeout  => 700,
  }
}
