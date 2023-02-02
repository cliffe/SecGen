#
class proftpd_1_3_5_mod_copy_remote_command_execution::config {
  require proftpd_1_3_5_mod_copy_remote_command_execution::install
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $website_dir = '/var/www/html' # If changed, the WebServer.sh script must be changed. 

  # Create /var/www/html/
  file { $website_dir:
    ensure  => 'directory',
    mode    => '0777',
    require => File['make-install'],
    notify  => File["${website_dir}/index.html"],
  }

  # Move index.html dummy website to /var/www/html/
  file { "${website_dir}/index.html":
    source  => 'puppet:///modules/proftpd_1_3_5_mod_copy_remote_command_execution/index.html',
    mode    => '0777',
    require => File[$website_dir],
    notify  => Exec['set-perms'],
  }

  # Set permissions for /var/www/html/
  exec { 'set-perms':
    command => "sudo chmod 777 -R ${website_dir}",
    require => File["${website_dir}/index.html"],
    notify  => File['/usr/bin/WebServer.sh'],
  }
  # Execution is now passed to the service.pp file.
}
