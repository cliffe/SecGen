class unrealirc_3281_backdoor::config
{
  
  File {
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
  }
  
  # Create config file
  $config_file = "${unrealirc_3281_backdoor::install_path}/unrealircd.conf"
  file { $config_file:
    ensure   => file,
    mode     => '0600',
    content  => template('unrealirc_3281_backdoor/unrealircd.conf.erb'),
    require  => Exec['unrealirc-dir'],
  }

  $tmp_directory = "${unrealirc_3281_backdoor::install_path}/tmp"
  file { $tmp_directory:
    ensure   => directory,
    mode     => '0777',
    require  => Exec['unrealirc-dir'],
  }

  # Create directory that will store included config files
  file { 'unrealirc_config_directory':
    path     => "${unrealirc_3281_backdoor::install_path}/config",
    ensure   => directory,
    require  => Exec['unrealirc-dir'],
  }
  
  if $unrealirc_3281_backdoor::use_ssl {
    $ssl_certificate = "${unrealirc_3281_backdoor::install_path}/server.cert.pem"
    $ssl_key = "${unrealirc_3281_backdoor::install_path}/server.key.pem"
    # This should fail if the variables are not declared
    file { $ssl_certificate:
      ensure => present,
      source => $unrealirc_3281_backdoor::ssl_cert,
    }
    file { $ssl_key:
      ensure => present,
      source => $unrealirc_3281_backdoor::ssl_key,
    }
  }
  
  $motd = "${unrealirc_3281_backdoor::install_path}/ircd.motd"
  if $unrealirc_3281_backdoor::motd {
    file { $motd:
      ensure => present,
      source => $unrealirc_3281_backdoor::motd,
    }
  } else {
    file { $motd:
      ensure => present,
      source => 'puppet:///modules/unrealirc_3281_backdoor/motd',
    }
  }

  # Define a default logger
  file { $unrealirc_3281_backdoor::log_path:
    ensure   => file,
    mode     => '0640',
  }
}