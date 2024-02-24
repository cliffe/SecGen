class policykit::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $username = $secgen_parameters['unix_username'][0]
  $password = $secgen_parameters['used_password'][0]

  # We require gnome-control-center for the exploit to work alongside policykit
  ensure_packages(['gnome-control-center'], {ensure => installed})

  user { $username:
    ensure   => present,
    managehome => true,
    shell    => '/bin/bash',
    password => pw_hash($password, 'SHA-512', 'mysalt'),
  }
  # Version -26 for the following packages are needed. (Debian) Buster was not originally vulnerable, however bullseye was. 
  -> file { '/tmp/libpolkit-gobject-1-0_0.105-26_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/libpolkit-gobject-1-0_0.105-26_amd64.deb',
  }
  -> package { 'policykit-gobject':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/libpolkit-gobject-1-0_0.105-26_amd64.deb'
  }
  -> file { '/tmp/libpolkit-agent-1-0_0.105-26_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/libpolkit-agent-1-0_0.105-26_amd64.deb',
  }
  -> package { 'policykit-agent':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/libpolkit-agent-1-0_0.105-26_amd64.deb'
  }
  -> file { '/tmp/policykit-1_0.105-26_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/policykit-1_0.105-26_amd64.deb',
  }
  -> package { 'policykit':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/policykit-1_0.105-26_amd64.deb'
  }

  # Leak a file containing a string/flag to /root/
  ::secgen_functions::leak_files { 'policykit-file-leak':
    storage_directory => '/root',
    leaked_filenames => $leaked_filenames,
    strings_to_leak => $strings_to_leak,
    leaked_from => "",
    mode => '0600'
  }
}
