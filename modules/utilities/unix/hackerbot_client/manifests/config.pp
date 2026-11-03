class hackerbot_client::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_key_pair  = parsejson($secgen_parameters['ssh_key_pair'][0])
  $public_key    = $ssh_key_pair['public']

  # Hackerbot connects as root with the key, so sshd must be installed and running.
  # Debian's default PermitRootLogin (prohibit-password) already allows root key
  # login; we deliberately don't override it, so a vulnerability module that sets
  # PermitRootLogin yes (e.g. ssh_root_login) still takes effect.
  package { 'openssh-server':
    ensure => installed,
  }

  service { 'ssh':
    ensure  => running,
    enable  => true,
    require => Package['openssh-server'],
  }

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