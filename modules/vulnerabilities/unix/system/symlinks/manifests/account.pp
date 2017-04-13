define symlinks::account($username, $password, $strings_to_leak, $leaked_filenames) {
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
    group             => managers,
    mode              => '0600',
    leaked_from       => "accounts_$username",
  }

  file { "/home/$username/prompt.c":
    owner  => $username,
    group  => $username,
    mode   => '0644',
    ensure => file,
    source => 'puppet:///modules/symlinks/prompt.c',
  }

  exec { "$username-compileandsetup1":
    cwd     => "/home/$username/",
    command => "gcc -o prompt prompt.c && sudo chown $username:shadow prompt && sudo chmod 2755 prompt",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
  }

}