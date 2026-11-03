class bludit_upload_images_exec::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/bludit-3-9-2'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Self-contained Apache (no puppetlabs-apache / apache_*_compatible). .php is
  # handed to php7_patched's php-fpm (127.0.0.1:9000). AllowOverride All lets
  # Bludit's .htaccess handle URL rewriting.
  ensure_packages(['apache2'])

  exec { 'bludit-apache-mods':
    command => 'a2enmod proxy proxy_fcgi rewrite',
    unless  => 'test -e /etc/apache2/mods-enabled/proxy_fcgi.load',
    require => Package['apache2'],
  }

  file { '/etc/apache2/ports.conf':
    ensure  => file,
    content => "Listen ${port}\n",
    require => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/bludit.conf':
    ensure  => file,
    content => "<VirtualHost *:${port}>\n  DocumentRoot ${docroot}\n  DirectoryIndex index.php\n  <Directory ${docroot}>\n    AllowOverride All\n    Require all granted\n  </Directory>\n  <FilesMatch \\.php$>\n    SetHandler \"proxy:fcgi://127.0.0.1:9000\"\n  </FilesMatch>\n  # CVE-2019-16113: MSF uploads the webshell to bl-content/tmp/.\n  # With FPM, AddType application/x-httpd-php in .htaccess has no effect\n  # (that is mod_php syntax); handle .png directly from the vhost so the\n  # exploit works. Requires security.limit_extensions = .php .png in FPM.\n  <Directory ${docroot}/bl-content/tmp>\n    <FilesMatch \\.png$>\n      SetHandler \"proxy:fcgi://127.0.0.1:9000\"\n    </FilesMatch>\n  </Directory>\n</VirtualHost>\n",
    require => Package['apache2'],
  }

  exec { 'bludit-apache-sites':
    command => 'a2dissite 000-default; a2ensite bludit',
    require => [File['/etc/apache2/sites-available/bludit.conf'], Exec['bludit-apache-mods']],
  }
  -> exec { 'restart-apache-bludit':
    command   => 'systemctl restart apache2; sleep 3',
    require   => File['/etc/apache2/ports.conf'],
    logoutput => true,
  }
}
