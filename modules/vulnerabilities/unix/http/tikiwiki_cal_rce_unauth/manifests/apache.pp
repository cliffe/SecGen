# Class: tikiwiki_cal_rce_unauth::apache
# Setup apache site and config
#
class tikiwiki_cal_rce_unauth::apache {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  $port = 80
  $docroot = '/var/www/tiki-14.1/'

  class { '::apache':
    default_vhost   => false,
  }

  ::apache::vhost { 'tikiwiki':
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
