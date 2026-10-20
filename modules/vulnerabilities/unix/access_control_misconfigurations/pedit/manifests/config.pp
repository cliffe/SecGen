class pedit::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_leak  = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  $binpath = ['/bin', '/usr/bin', '/sbin', '/usr/sbin']

  file { '/etc/sysctl.d/99-pedit-userns.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "kernel.unprivileged_userns_clone = 1\nuser.max_user_namespaces = 15000\n",
  }

  exec { 'pedit-apply-userns-sysctl':
    command  => 'sysctl -w kernel.unprivileged_userns_clone=1 ; sysctl -w user.max_user_namespaces=15000',
    provider => 'shell',
    path     => $binpath,
    require  => File['/etc/sysctl.d/99-pedit-userns.conf'],
  }

  exec { 'pedit-unblacklist-act-pedit':
    command  => "sed -i '/act_pedit/d' /etc/modprobe.d/*.conf",
    provider => 'shell',
    path     => $binpath,
    onlyif   => 'grep -rlq act_pedit /etc/modprobe.d/',
  }

  exec { 'pedit-hold-kernel':
    command  => 'apt-mark hold linux-image-amd64 "linux-image-$(uname -r)"',
    provider => 'shell',
    path     => $binpath,
    unless   => 'apt-mark showhold | grep -q linux-image',
  }

  ::secgen_functions::leak_files { 'pedit-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    group             => 'root',
    mode              => '0600',
    leaked_from       => 'pedit',
  }
}
