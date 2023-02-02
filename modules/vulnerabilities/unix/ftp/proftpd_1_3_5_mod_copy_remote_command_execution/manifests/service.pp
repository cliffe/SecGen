#
class proftpd_1_3_5_mod_copy_remote_command_execution::service {
  require proftpd_1_3_5_mod_copy_remote_command_execution::config
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $script_dir = '/usr/bin'
  $service_dir = '/etc/systemd/system' # If changed, proftpd.service & website.service files must be changed.

  # Copy BusyBox script to /usr/bin/
  file { "${script_dir}/WebServer.sh":
    source  => 'puppet:///modules/proftpd_1_3_5_mod_copy_remote_command_execution/WebServer.sh',
    mode    => '0777',
    require => Exec['set-perms'],
    notify  => File["${service_dir}/website.service"],
  }

  # Copy BusyBox service file to /etc/systemd/system/
  file { "${service_dir}/website.service":
    source  => 'puppet:///modules/proftpd_1_3_5_mod_copy_remote_command_execution/website.service',
    mode    => '0777',
    require => File["${script_dir}/WebServer.sh"],
    notify  => File["${service_dir}/proftpd.service"],
  }

  # Copy proftpd service file
  file { "${service_dir}/proftpd.service":
    source  => 'puppet:///modules/proftpd_1_3_5_mod_copy_remote_command_execution/proftpd.service',
    mode    => '0777',
    require => File["${service_dir}/website.service"],
    notify  => Service['website'],
  }

  # Start services

  # Web Server
  service { 'website':
    ensure  => running,
    enable  => true,
    require => File["${service_dir}/proftpd.service"],
    notify  => Service['proftpd'],
  }

  # Proftpd
  service { 'proftpd':
    ensure  => running,
    enable  => true,
    require => Service['website'],
  }
  # End of Module.
}
