define relative_path_suid_hardlinks::account($username, $password, $strings_to_leak, $leaked_filenames) {
  ::accounts::user { $username:
    shell      => '/bin/bash',
    password   => pw_hash($password, 'SHA-512', 'mysalt'),
    managehome => true,
    home_mode  => '0755',
  }

  # Leak strings in a text file in the users home directory
  ::secgen_functions::leak_files { "$username-file-leak":
    storage_directory => "/home/$username/",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $username,
    group             => $username,
    mode              => '0600',
    leaked_from       => "accounts_$username",
  }

  file { "/home/$username/access_my_flag.c":
    owner  => $username,
    group  => $username,
    mode   => '0644',
    ensure => file,
    source => 'puppet:///modules/relative_path_suid_hardlinks/access_my_flag.c',
  } ->

  exec { "$username-compileandsetup2":
    cwd     => "/home/$username/",
    command => "gcc -o access_my_flag access_my_flag.c && sudo chown $username access_my_flag && sudo chmod 4755 access_my_flag",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
  }

  # overwrite any existing content (exists on Debian Buster)
  file { '/etc/sysctl.d/protect-links.conf':
    content => "fs.protected_hardlinks = 0",
  }

}
