#
class apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = 'websvr'
  $install_dir = '/opt/Apache_2.4.49'


# Install dependancies build-essential, libpcre3, libpcre3-dev, libapr1-dev, libaprutil1-dev & pcre2-utils.
  package { 'build-essential':
    ensure => installed,
    notify => Package['libpcre3'],
  }
  package { 'libpcre3':
    ensure  => installed,
    require => Package['build-essential'],
    notify  => Package['libpcre3-dev'],
  }
  package { 'libpcre3-dev':
    ensure  => installed,
    require => Package['libpcre3'],
    notify  => Package['libapr1-dev'],
  }
  package { 'libapr1-dev':
    ensure  => installed,
    require => Package['libpcre3-dev'],
    notify  => Package['libaprutil1-dev'],
  }
  package { 'libaprutil1-dev':
    ensure  => installed,
    require => Package['libapr1-dev'],
    notify  => Package['pcre2-utils'],
  }
  package { 'pcre2-utils':
    ensure  => installed,
    require => Package['libaprutil1-dev'],
    notify  => User[$user],
  }

  # Create install directory.
  file { $install_dir:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0755',
    require => User[$user],
    notify  => File["${install_dir}/httpd-2.4.49.tar.gz"],
  }

  # Move tar ball to /opt/Apache_2.4.49/ directory.
  file { "${install_dir}/httpd-2.4.49.tar.gz":
    owner   => $user,
    mode    => '0755',
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/httpd-2.4.49.tar.gz',
    require => File[$install_dir],
    notify  => Exec['mellow-file'],
  }

  # Extract tar ball.
  exec { 'mellow-file':
    command => 'sudo tar -xzvf httpd-2.4.49.tar.gz',
    cwd     => $install_dir,
    creates => "${install_dir}/httpd-2.4.49/",
    require => File["${install_dir}/httpd-2.4.49.tar.gz"],
    notify  => Exec['configure'],
  }

  # In /httpd-2.4.49/ run sudo ./configure.
  exec { 'configure':
    command => 'sudo ./configure',
    cwd     => "${install_dir}/httpd-2.4.49/",
    require => Exec['mellow-file'],
    notify  => Exec['make'],
  }

  # sudo make.
  # Compile binaries.
  exec { 'make':
    command => 'sudo make',
    cwd     => "${install_dir}/httpd-2.4.49/",
    require => Exec['configure'],
    notify  => Exec['make-install'],
  }

  # sudo make install.
  # Install application from compiled binaries.
  exec { 'make-install':
    command => 'sudo make install',
    cwd     => "${install_dir}/httpd-2.4.49/",
    require => Exec['make'],
    notify  => Exec['remove-config'],
  }
  # Execution now passes to the config.pp file.
}
