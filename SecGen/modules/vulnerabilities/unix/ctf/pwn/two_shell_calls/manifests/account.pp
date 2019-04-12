define two_shell_calls::account($username, $password, $strings_to_leak, $leaked_filenames) {
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
    group             => 'managers',
    mode              => '0600',
    leaked_from       => "accounts_$username",
  }

  file { "/home/$username/shell.c":
    owner  => $username,
    group  => $username,
    mode   => '0644',
    ensure => file,
    source => 'puppet:///modules/two_shell_calls/shell.c',
  }

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')

  if ('none' in $strings_to_leak ){
    exec { "$username-compileandsetup1":
      cwd     => "/home/$username/",
      command => "gcc -o shell shell.c && sudo chown $username:managers shell && sudo chmod 2755 shell",
      path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      require => Package['build-essential', 'gcc-multilib']
    }
  } else {
    exec { "$username-compileandsetup2":
      cwd     => "/home/$username/",
      command => "gcc -o shell shell.c && sudo chown $username:managers shell && sudo chmod 4750 shell",
      path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      require => Package['build-essential', 'gcc-multilib']
    }
  }

}