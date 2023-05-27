# Class: glpi_php_injection::install
# Install process for GLPI
# https://github.com/glpi-project/glpi/releases/ - v9.5.8 is used here
class glpi_php_injection::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  ensure_packages(['mariadb-server', 'php',
  'php-curl',
  'php-gd',
  'php-intl',
  'php-mysql',
  'php-mbstring',
  'php-xml',
  'php-ldap',
  'php-apcu',
  'php-xmlrpc',
  'php-zip',
  'php-bz2'], { ensure => 'installed'})

  $releasename = 'glpi-9.5.8.tgz'
  file { "/tmp/${releasename}":
    ensure => file,
    source => "puppet:///modules/glpi_php_injection/${releasename}",
  }
  -> exec { 'extract-glpi':
    cwd     => '/tmp',
    command => "tar -xf ${releasename}",
    creates => '/tmp/glpi'
  }
  -> exec { 'move-glpi':
    cwd     => '/tmp',
    command => 'mv glpi/ /var/www/html',
    creates => '/var/www/html/glpi/',
  }
  -> exec { 'chmod-glpi':
    command => 'chmod 755 -R /var/www/html/glpi/',
  }
  -> exec { 'chown-glpi':
    command => 'chown www-data:www-data -R /var/www/html/glpi/',
  }

}
