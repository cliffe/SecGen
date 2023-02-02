#
class proftpd_1_3_5_mod_copy_remote_command_execution::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = 'proftpd'
  $user_home = "/home/${user}"
  $base_dir = '/opt'
  $install_dir = "${base_dir}/proftpd-1.3.5"
  $website_dir = '/var/www/html/'

  # Create user - User creation not really needed for this vulnerability.
  user { $user:
    ensure     => present,
    uid        => '666',
    gid        => 'root',#
    home       => "${user_home}/",
    managehome => true,
    notify     => Package['build-essential'],
  }

  # Install dependancies.
  package { 'build-essential':
    ensure  => installed,
    require => User[$user],
    notify  => Package['gcc-multilib'],
  }
  package { 'gcc-multilib':
    ensure  => installed,
    require => Package['build-essential'],
    notify  => File["${base_dir}/proftpd_1_3_5.tar.gz"],
  }

  # Copy tar ball.
  file { "${base_dir}/proftpd_1_3_5.tar.gz":
    source  => 'puppet:///modules/proftpd_1_3_5_mod_copy_remote_command_execution/proftpd_1_3_5.tar.gz',
    owner   => $user,
    mode    => '0777',
    require => Package['gcc-multilib'],
    notify  => Exec['mellow-file'],
  }

  # Extract.
  exec { 'mellow-file':
    cwd     => $base_dir,
    command => 'sudo tar -xzvf proftpd_1_3_5.tar.gz',
    creates => "${base_dir}/proftpd-1.3.5/",
    require => File["${base_dir}/proftpd_1_3_5.tar.gz"],
    notify  => Exec['configure'],
  }

  # Configure.
  exec { 'configure':
    cwd     => $install_dir,
    command => 'sudo ./configure --with-modules=mod_copy',
    require => Exec['mellow-file'],
    notify  => Exec['make'],
  }

  # Compile binaries.
  exec { 'make':
    cwd     => $install_dir,
    command => 'sudo make',
    require => Exec['configure'],
    notify  => Exec['make-install'],
  }

  # Install binaries.
  exec { 'make-install':
    cwd     => $install_dir,
    command => 'sudo make install',
    require => Exec['make'],
    notify  => File[$website_dir],
  }
  # Execution is now passed to the config.pp file.
}
