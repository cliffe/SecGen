# Class: tikiwiki_cal_rce_unauth::install
# Tiki Wiki install process
#
class tikiwiki_cal_rce_unauth::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  ensure_packages(['php'
  ,'php-xml'
  ,'mariadb-server'
  ,'php-mysql'
  ,'libapache2-mod-php'
  ,'php-common'
  ,'php-sqlite3'
  ,'php-curl'
  ,'libmcrypt-dev'
  ,'php-intl'
  ,'php-mbstring'
  ,'php-xmlrpc'
  ,'php-gd'
  ,'php-cli'
  ,'php-zip'], { ensure => 'installed'})

  file { '/tmp/tiki-14.1.tar.gz':
    ensure => present,
    source => 'puppet:///modules/tikiwiki_cal_rce_unauth/tiki-14.1.tar.gz',
  }
  -> exec { 'extract-tiki':
    cwd     => '/tmp/',
    command => 'tar -xf tiki-14.1.tar.gz -C /var/www/',
  }
  -> exec { 'chmod-tiki-directories':
    cwd     => '/var/www/',
    command => 'find /var/www/tiki-14.1 -type d -exec chmod 777 {} \;',
  }
  -> exec { 'chmod-tiki-files':
    cwd     => '/var/www/',
    command => 'find /var/www/tiki-14.1 -type f -exec chmod 644 {} \;'
  }
}
