class erlang_otp_ssh_rce::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  package { 'erlang':
    ensure => installed,
  }

  ensure_packages(['screen', 'openssh-client'])

  user { 'erlang_ssh':
    ensure     => present,
    home       => '/home/erlang_ssh',
    managehome => true,
    shell      => '/bin/bash',
  }

  group { 'erlang_ssh':
    ensure => present,
  }
}