class erlang_otp_ssh_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_port = pick($secgen_parameters['ssh_port'], ['2222'])
  $port = $ssh_port[0]

  exec { 'compile-erlang-ssh-daemon':
    command => "erlc /opt/erlang_ssh/ssh_daemon.erl",
    path    => ['/usr/bin', '/bin'],
    creates => '/opt/erlang_ssh/ssh_daemon.beam',
    require => [
      Package['erlang'],
      File['/opt/erlang_ssh/ssh_daemon.erl'],
    ],
  }

  exec { 'generate-ssh-host-keys':
    command => 'ssh-keygen -t rsa -b 2048 -f /opt/erlang_ssh/ssh_keys/ssh_host_rsa_key -N "" && ssh-keygen -t ecdsa -b 256 -f /opt/erlang_ssh/ssh_keys/ssh_host_ecdsa_key -N ""',
    path    => ['/usr/bin', '/bin'],
    creates => '/opt/erlang_ssh/ssh_keys/ssh_host_rsa_key',
    require => File['/opt/erlang_ssh/ssh_keys'],
  }

  exec { 'start-erlang-ssh-daemon':
    command     => "screen -dmS erlang_ssh bash -c 'erl -noshell -eval \"ssh_daemon:start(${port})\"'",
    path        => ['/usr/bin', '/bin'],
    unless      => 'screen -list | grep -q erlang_ssh',
    require     => [
      Exec['compile-erlang-ssh-daemon'],
      Exec['generate-ssh-host-keys'],
      Package['screen'],
    ],
  }

  exec { 'verify-ssh-port-listening':
    command   => "ss -tlnp | grep -q ':${port}'",
    path      => ['/usr/bin', '/bin'],
    tries     => 5,
    try_sleep => 2,
    require   => Exec['start-erlang-ssh-daemon'],
  }
}