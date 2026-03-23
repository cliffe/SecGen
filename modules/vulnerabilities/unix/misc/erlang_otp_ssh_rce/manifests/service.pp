class erlang_otp_ssh_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_port = pick($secgen_parameters['ssh_port'], ['2222'])
  $port = $ssh_port[0]

  exec { 'generate-ssh-host-keys':
    command => 'ssh-keygen -t rsa -b 2048 -f /opt/erlang_ssh/ssh_keys/ssh_host_rsa_key -N "" && ssh-keygen -t ecdsa -b 256 -f /opt/erlang_ssh/ssh_keys/ssh_host_ecdsa_key -N ""',
    path    => ['/usr/bin', '/bin'],
    creates => '/opt/erlang_ssh/ssh_keys/ssh_host_rsa_key',
    require => File['/opt/erlang_ssh/ssh_keys'],
  }

  exec { 'start-erlang-ssh-daemon':
    command     => "screen -dmS erlang_ssh escript /opt/erlang_ssh/start_ssh.escript ${port}",
    path        => ['/usr/bin', '/bin'],
    unless      => 'screen -list | grep -q erlang_ssh',
    require     => [
      Exec['generate-ssh-host-keys'],
      File['/opt/erlang_ssh/start_ssh.escript'],
      Package['screen'],
    ],
  }
}