#
class apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::config {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = 'websvr'
  $user_home = "/home/${user}"
  $install_dir = '/opt/Apache_2.4.49'
  $webpage_dir = '/usr/local/apache2/htdocs'
  $config_dir = '/usr/local/apache2/conf'
  $service_file_dir = '/etc/systemd/system'

  # Create user account.
  user { $user:
    ensure     => 'present',
    uid        => '666',
    gid        => 'root',#
    home       => $user_home,
    password   => 'Password123',
    managehome => true,
    require    => Package['pcre2-utils'],
    notify     => File[$install_dir],
  }

  # Remove current config.
  exec { 'remove-config':
    command => "sudo rm -f ${config_dir}/httpd.conf",
    require => Exec['make-install'],
    notify  => Exec['remove-default-index'],
  }

  # Remove default index.html.
  exec { 'remove-default-index':
    command => "sudo rm -f ${webpage_dir}/index.html",
    require => Exec['remove-config'],
    notify  => File["${webpage_dir}/index.html"],
  }

  # Add webpage. /usr/local/apache2/htdocs
  file { "${webpage_dir}/index.html":
    mode    => '0755',
    owner   => $user,
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/index.html',
    require => Exec['remove-default-index'],
    notify  => File["${config_dir}/httpd.conf"],
  }

  # Copy httpd.conf configuration file to /usr/local/apache2/conf/httpd.conf
  file { "${config_dir}/httpd.conf":
    mode    => '0755',
    owner   => $user,
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/httpd.conf',
    require => File["${webpage_dir}/index.html"],
    notify  => File["${service_file_dir}/httpd.service"],
  }
  # Execution now passed to the service.pp file.
}
