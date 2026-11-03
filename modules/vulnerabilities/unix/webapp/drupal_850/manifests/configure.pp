class drupal_850::configure {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  Exec { path => ['/bin', '/usr/bin','/sbin','/usr/sbin']}

  # PHP is served by php7_patched's php-fpm (wired into Apache in apache.pp).
  # The database is packaged MariaDB, installed and running by this point.

  # Drupal configuration using pre-setup files (full config can't be done via
  # the CLI). settings.php ships pointing at 'localhost'; force TCP 127.0.0.1 so
  # php7_patched's mysqlnd reaches MariaDB regardless of socket path.
  exec {'extract-drupal-setup':
    command => 'tar -xzf /usr/local/src/drupal_pre_setup.tar.gz -C /',
  } ->
  exec {'set-drupal-permissions':
    command => 'chown -R www-data:www-data /var/www/drupal-8.5.0',
  } ->
  exec {'drupal-db-host-tcp':
    command => "sed -i \"s/'host' => 'localhost'/'host' => '127.0.0.1'/\" /var/www/drupal-8.5.0/sites/default/settings.php",
    onlyif  => "grep -q \"'host' => 'localhost'\" /var/www/drupal-8.5.0/sites/default/settings.php",
  } ->
  exec {'create-drupal-database':
    command => 'mysql -u root -e "CREATE DATABASE IF NOT EXISTS drupal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"',
  } ->
  exec {'create-drupal-user':
    command => 'mysql -u root -e "CREATE USER IF NOT EXISTS \'drupal\'@\'127.0.0.1\' IDENTIFIED BY \'drupalpass\'; GRANT ALL PRIVILEGES ON drupal.* TO \'drupal\'@\'127.0.0.1\'; CREATE USER IF NOT EXISTS \'drupal\'@\'localhost\' IDENTIFIED BY \'drupalpass\'; GRANT ALL PRIVILEGES ON drupal.* TO \'drupal\'@\'localhost\'; FLUSH PRIVILEGES;"',
  } ->
  # The dump is a newer-MariaDB mariadb-dump whose "sandbox mode" first line
  # (/*M!999999\- ... */) the buster MariaDB 10.3 client rejects ("Unknown
  # command '\-'"); strip it before importing.
  exec {'import-drupal-sql':
    command   => "sed '/enable the sandbox mode/d' /usr/local/src/drupal_pre_setup.sql | mysql -u root drupal",
    provider  => shell,
    timeout   => 600,
    logoutput => true,
  }

  # Pre-exploitation hint in robots.txt, and the flag in a plain file under the
  # Drupal site dir (found post-RCE as www-data). The flag is NOT injected into
  # settings.php: a generated flag can be multi-line and contain '|', which
  # breaks PHP parsing of settings.php.
  file_line { 'pre-leak-robots-txt':
    path    => '/var/www/drupal-8.5.0/robots.txt',
    line    => "# ${join($strings_to_pre_leak, ' ')}",
    require => Exec['extract-drupal-setup'],
  }
  file { '/var/www/drupal-8.5.0/sites/default/flag.txt':
    ensure  => file,
    content => "${join($strings_to_leak, "\n")}\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    require => Exec['set-drupal-permissions'],
  }
}
