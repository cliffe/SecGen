#
class apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::service {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $config_dir = '/usr/local/apache2/conf'
  $service_file_dir = '/etc/systemd/system'
  $bin_dir = '/usr/local/apache2/bin'

  # Move service file to correct location.
  file { "${service_file_dir}/httpd.service":
    ensure  => present,
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/httpd.service',
    owner   => 'root',
    mode    => '0777',
    require => File["${config_dir}/httpd.conf"],
    notify  => Exec['start-httpd'],
  }

  # Start httpd service.
  exec { 'start-httpd':
    command => 'sudo ./httpd',
    cwd     => $bin_dir,
    require => File["${service_file_dir}/httpd.service"],
    notify  => Cron['start-httpd-cron'],
  }

  # Create Cron job to start the Apache service after system reboot.
  cron { 'start-httpd-cron':
    command => "sudo ${bin_dir}/httpd",
    special => 'reboot',
    require => Exec['start-httpd'],
    notify  => Service['httpd'],
  }

  # Make sure the Apache service is running.
  service { 'httpd':
    ensure  => 'running',
    enable  => true,
    require => File["${service_file_dir}/httpd.service"],
  }
  # End of Module.
}
