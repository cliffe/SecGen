class hackerbot_client::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_key_pair  = parsejson($secgen_parameters['ssh_key_pair'][0])
  $public_key    = $ssh_key_pair['public']

  file { '/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { '/root/.ssh/authorized_keys':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "${public_key}\n",
    require => File['/root/.ssh'],
  }
}