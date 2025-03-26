class gravcms::install {
  ensure_packages(['apache2', 'php', 'libapache2-mod-php', 'php-mbstring', 'php-curl', 'php-dom', 'php-xml', 'php-zip', 'php-gd'])

  Exec {path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
    environment => ['http_proxy=http://172.22.0.51:3128',
      'https_proxy=http://172.22.0.51:3128',
      'ftp_proxy=http://172.22.0.51:3128'] }

  exec {'enable-mod-rewrite':
    command => 'sudo a2enmod rewrite',
  } ->
  file {'/var/www/html':
    ensure => directory,
    owner => 'www-data',
  } ->
  file {'/var/www/html/grav_admin.zip':
    source => 'puppet:///modules/gravcms/grav-admin.zip',
    owner => 'www-data',
    group => 'www-data',
  } ->
  exec {'extract-grav-cmd':
    command => 'unzip -x grav_admin.zip; rm grav_admin.zip',
    cwd => '/var/www/html/',
    user => 'www-data',
    creates => '/var/www/html/grav-admin',
  } ->
  exec {'enable-htaccess':
    command => 'sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/" /etc/apache2/apache2.conf',
  } ->
  exec {'enable-web-server':
    command => 'systemctl enable apache2',
  } ->
  exec {'restart-web-server':
    command => 'systemctl restart apache2',
  }

  $leaked_filenames = ["flag1"]
  $strings_to_leak = ["we_love_the_insecure_cms_we_do"]

  ::secgen_functions::leak_files { 'gravcms':
    storage_directory => "/var/www/html/grav-admin",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => 'gravcms',
  }
}
