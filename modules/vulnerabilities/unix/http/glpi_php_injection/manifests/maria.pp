# Class: glpi_php_injection::maria
# MariaDB database and GLPI schema initialisation.
#
class glpi_php_injection::maria {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  $db_name = 'glpidb'
  $db_user = 'user'
  $db_pass = 'demo'

  # Account and test-database hardening (anonymous users, the test database,
  # etc.) is already done by the required mysql service module's
  # mysql::server::account_security; no separate secure-install step is needed.

  mysql::db { 'glpidb':
    user     => $db_user,
    password => $db_pass,
    dbname   => $db_name,
    host     => 'localhost',
    grant    => ['ALL'],
  }

  # GLPI provides a CLI installer.
  # https://glpi-install.readthedocs.io/en/latest/command-line.html#cdline-install
  # Note: -P is the *database* port (not the web vhost port) - the mysql
  # service module listens on the standard 3306.  `php` here is the CLI PHP
  # 7.4 binary set as default by install.pp; GLPI 9.5.8's db:install corrupts
  # its own bundled SQL schema under PHP 8.2 (a quoted column default goes
  # missing, producing a MariaDB syntax error on the first CREATE TABLE).
  Mysql::Db['glpidb']
  -> exec { 'glpi-cli-install':
    cwd       => '/var/www/html/glpi/bin/',
    command   => "php console db:install -f -H localhost -P 3306 -d ${db_name} -u ${db_user} -p ${db_pass}",
    logoutput => true,
    # Creating GLPI's schema takes minutes; Puppet's default 300 s ran out on a busy host.
    timeout   => 1800,
  }
  # db:install runs as root (Puppet execs default to root), leaving
  # files/_log/php-errors.log and other touched paths root-owned.  Apache
  # can't write to them as www-data and GLPI 500s on every request.
  -> exec { 'glpi-fix-ownership-after-install':
    command => 'chown -R www-data:www-data /var/www/html/glpi/files',
  }
}
