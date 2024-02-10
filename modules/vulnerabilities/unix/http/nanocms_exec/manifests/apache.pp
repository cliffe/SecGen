# Class: nanocms::apache
# Configures the apache resources
#
class nanocms_exec::apache {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $docroot = '/var/www/nanocms'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => 'absent',
  }

  class { '::apache':
    default_vhost   => false,
    default_mods    => ['rewrite'], # php5 via separate module
    overwrite_ports => false,
    mpm_module      => 'prefork'
  }

  -> ::apache::vhost { 'nanocms':
    port    => $port,
    docroot => $docroot,
  }

  # restart apache
  -> exec { 'restart-apache-nanocms':
    command   => 'service apache2 restart',
    logoutput => true
  }
  -> exec { 'wait-apache-nanocms':
    command => 'sleep 4',
  }
}
