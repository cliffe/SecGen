# Class: linuxki::apache
# Apache configuration for linuxki
#
class linuxki_rce::apache {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
  }

  class { '::apache':
    default_vhost   => false,
    default_mods    => ['rewrite'], # php5 via separate module
    overwrite_ports => false,
    mpm_module      => 'prefork',
  }
  -> ::apache::vhost { 'linuxki':
    port        => $port,
    options     => 'FollowSymLinks',
    override    => 'All',
    docroot     => '/opt/',
    directories => [{
      path  => '/opt/',
      allow => 'from all',
    },{
      path  => '/opt/linuxki/',
      allow => 'from all',
    }],
  }

  $dirmatch = '<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
  </Directory>
  
  <Directory /opt/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
  </Directory>'

  # ugly way to append to the file... clean up potentially?
  exec { 'append-directories':
    command   => "grep -qE '<Directory (\/opt\/)>|<Directory (\/var\/www\/)>' /etc/apache2/apache2.conf && echo '' || echo \"${dirmatch}\" | sudo tee -a /etc/apache2/apache2.conf",
  }
  # restart apache
  -> exec { 'restart-apache-linuxki':
    command   => 'service apache2 restart',
    logoutput => true
  }
  -> exec { 'wait-apache-linuxki':
    command => 'sleep 4',
  }
}
