class erlang_otp_ssh_rce::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $ssh_username = $secgen_parameters['unix_username'][0]
  $ssh_home = "/home/${ssh_username}"

  file { '/opt/erlang_ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/opt/erlang_ssh/ssh_keys':
    ensure => directory,
    owner  => $ssh_username,
    group  => $ssh_username,
    mode   => '0700',
  }

  file { '/opt/erlang_ssh/start_ssh.escript':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/erlang_otp_ssh_rce/start_ssh.escript',
    require => File['/opt/erlang_ssh'],
  }

  ::secgen_functions::leak_files { 'erlang_ssh-flag':
    storage_directory => $ssh_home,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $ssh_username,
    mode              => '0600',
    leaked_from       => 'erlang_otp_ssh_rce',
  }
}