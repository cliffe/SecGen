class drupal_850::configure {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  Exec { path => ['/bin', '/usr/bin','/sbin','/usr/sbin']}
  
  # Apache configuration
  exec {'disable-php5':
    command => 'a2dismod php5 php5.6 2>/dev/null || true', #ignore output
  } ->

  exec {'enable-php7.2':
    command => 'a2enmod php7.2',
  } ->

  exec {'restart-apache':
    command => 'systemctl restart apache2',
  }
  
  # MySQL configuration
  file { '/var/lib/mysql':
    ensure => directory,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0750',
  } ->
  exec {'stop-mariadb':
    command => 'systemctl stop mariadb ; systemctl disable mariadb',
  } ->
  exec {'clean-after-purge':
    command => 'rm -rf /var/lib/mysql/* && sleep 1',
    require => File['/var/lib/mysql'],
  } ->
  exec {'initialize-mysql':
    command => '/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql --lc-messages-dir=/usr/local/mysql/share',
    logoutput => true,
  } ->
  exec {'reload-systemd-mysql':
    command => 'systemctl daemon-reload',
  } ->
  exec {'enable-mysql':
    command => 'systemctl enable mysql',
  } ->
  exec {'start-mysql':
    command => 'systemctl start mysql',
  } ->

  # Drupal configuration using presetup files as can't configure fully via command line. Can still be customized after setup.
  # sudo tar -czf /tmp/drupal_site_backup.tar.gz /var/www/drupal-8.5.0/ - command used to backup existing site, can be configured manually then copied to change it.
  # mysqldump -u root drupal > drupal_backup.sql - command used to backup existing database.
  
  exec {'extract-drupal-setup':
    command => 'tar -xzf /usr/local/src/drupal_pre_setup.tar.gz -C /',
  } ->
  exec {'set-drupal-permissions':
    command => 'chown -R www-data:www-data /var/www/drupal-8.5.0',
  } ->
  exec {'create-drupal-database':
    command => 'mysql -u root -e "CREATE DATABASE IF NOT EXISTS drupal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"',
  } ->
  exec {'create-drupal-user':
    command => 'mysql -u root -e "CREATE USER IF NOT EXISTS \'drupal\'@\'localhost\' IDENTIFIED BY \'drupalpass\'; GRANT ALL PRIVILEGES ON drupal.* TO \'drupal\'@\'localhost\'; FLUSH PRIVILEGES;"',
  } ->
  exec {'import-drupal-sql':
    command => 'mysql -u root drupal < /usr/local/src/drupal_pre_setup.sql',
    timeout => 600,
  }

  file_line { 'pre-leak-robots-txt':
    path    => '/var/www/drupal-8.5.0/robots.txt',
    line    => "# ${strings_to_pre_leak}",
    require => Exec['extract-drupal-setup'],
  }
  file_line { 'leak-flag-settings':
    path  => '/var/www/drupal-8.5.0/sites/default/settings.php',
    line  => "// ${strings_to_leak}",
    require => Exec['extract-drupal-setup'],
  }

  # TODO: 
  # - Figure out how to dynamically set the front page so a flag can be leaked or it can be used for organisations.
  # - Enable the REST module to make it vulnerable to CVE-2019-6340 as well.

}

