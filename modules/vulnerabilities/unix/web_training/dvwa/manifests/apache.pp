class dvwa::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $db_password = $secgen_parameters['db_password'][0]
  $docroot = '/var/www/dvwa'

  # TODO: there is probably a better way to get the PHP module name
  notice("AAAA operatingsystem: ${operatingsystem} operatingsystemrelease: ${operatingsystemrelease}")

  if ($operatingsystem == 'Debian' or $operatingsystem == 'Kali') {
    case $operatingsystemrelease {
       /^(12).*/: { # do 12.x bookworm stuff
        $php_version = "php8.2"
        ensure_packages(["default-mysql-server", 'php-mysqli'])
      }
      /^(10).*/: { # do 10.x buster stuff
        $php_version = "php7.3"
        ensure_packages(["mysql-server", 'php-mysqli'])
      }
      /^(9).*/: { # do 9.x stretch stuff
        $php_version = "php7.0"
        ensure_packages(["mysql-server", 'php-mysqli'])
      }
      /^7.*/: { # do 7.x wheezy stuff
        $php_version = "php"
        ensure_packages(["mysql-server", 'php-mysqli'])
      }
      'kali-rolling': { # do kali
        # Kali rolling ships PHP 8.4 (php8.2-mysql is no longer in its repository).
        # php-mysql is the version-independent metapackage.
        $php_version = "php8.4"
        ensure_packages(['php-mysql'])
      }
      default: {
        $php_version = "php"
      }
    }
  } else {
    $php_version = "php"
  }
  ensure_packages(['libapache2-mod-php'])
  ensure_packages(['php', 'php-gd'])


  class { '::apache':
    default_vhost => false,
    default_mods => $php_version,
    mpm_module => 'prefork',
  } ->

  ::apache::vhost { 'dvwa':
    priority => '05', # ahead of the apache module's own vhost on the same port
    port    => $port,
    docroot => $docroot,
    notify => Tidy['dvwa remove default site']
  } ->

  exec { 'enable php module':
    command  => "a2enmod $php_version",
    provider => shell,
  }


  # mysql_user{ 'dvwa_user@localhost':
  #   ensure        => present,
  #   password_hash => mysql_password($db_password)
  # } ->

  mysql::db { 'dvwa_database':
    user     => 'dvwa_user',
    password => $db_password,
    host     => 'localhost',
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP'],
  }

#  mysql_grant{'dvwa_user@localhost/dvwa_database.*':
#    user       => 'dvwa_user@localhost',
#    table      => 'dvwa_database.*',
#    privileges => ['ALL'],
#  }

  ensure_resource('tidy','dvwa remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})

}
