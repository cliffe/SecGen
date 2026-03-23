class erlang_otp_ssh_rce::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $ssh_port = pick($secgen_parameters['ssh_port'], ['2222'])
  $port = $ssh_port[0]

  file { '/opt/erlang_ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/opt/erlang_ssh/ssh_keys':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    before => File['/opt/erlang_ssh/ssh_daemon.erl'],
  }

  file { '/opt/erlang_ssh/ssh_daemon.erl':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('erlang_otp_ssh_rce/ssh_daemon.erl.erb'),
  }

  file { '/opt/erlang_ssh/start_ssh.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('erlang_otp_ssh_rce/start_ssh.sh.erb'),
  }

  ::secgen_functions::leak_files { 'erlang_ssh-flag':
    storage_directory => '/home/erlang_ssh',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'erlang_ssh',
    mode              => '0600',
    leaked_from       => 'erlang_otp_ssh_rce',
  }
}