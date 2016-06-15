class unrealirc::config
{
  
  File {
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
  }
  
  # Create config file
  $config_file = "${unrealirc::install_path}/unrealircd.conf"
  file { $config_file:
    ensure   => file,
    mode     => '0600',
    content  => template('unrealirc/unrealircd.conf.erb'),
    require  => Exec['unrealirc-dir'],
  }

  $tmp_directory = "${unrealirc::install_path}/tmp"
  file { $tmp_directory:
    ensure   => directory,
    mode     => '0777',
    require  => Exec['unrealirc-dir'],
  }

  # Create directory that will store included config files
  file { 'unrealirc_config_directory':
    path     => "${unrealirc::install_path}/config",
    ensure   => directory,
    require  => Exec['unrealirc-dir'],
  }
  
  if $unrealirc::use_ssl {
    $ssl_certificate = "${unrealirc::install_path}/server.cert.pem"
    $ssl_key = "${unrealirc::install_path}/server.key.pem"
    # This should fail if the variables are not declared
    file { $ssl_certificate:
      ensure => present,
      source => $unrealirc::ssl_cert,
    }
    file { $ssl_key:
      ensure => present,
      source => $unrealirc::ssl_key,
    }
  }
  
  $motd = "${unrealirc::install_path}/ircd.motd"
  if $unrealirc::motd {
    file { $motd:
      ensure => present,
      source => $unrealirc::motd,
    }
  } else {
    file { $motd:
      ensure => present,
      source => 'puppet:///modules/unrealirc/motd',
    }
  }

  # Define a default logger
  file { $unrealirc::log_path:
    ensure   => file,
    mode     => '0640',
  }
}