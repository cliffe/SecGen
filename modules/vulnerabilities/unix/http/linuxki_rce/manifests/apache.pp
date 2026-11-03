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
    default_mods    => ['rewrite'], # PHP via separate module, enabled below
    overwrite_ports => false,
    mpm_module      => 'prefork',
  }
  # The php7 utility module (a <requires> dependency) installs PHP 7.4 but
  # deliberately never touches Apache, since apache2 doesn't exist at that
  # point in provisioning - so enabling it in Apache is this module's job.
  -> exec { 'enable-apache-php7-linuxki':
    command => 'a2enmod php7.4',
  }
  -> ::apache::vhost { 'linuxki':
    priority => '05', # ahead of the apache module's own vhost on the same port
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
