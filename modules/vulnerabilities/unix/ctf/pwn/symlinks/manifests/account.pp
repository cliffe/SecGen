define symlinks::account($username, $password, $strings_to_leak, $leaked_filenames) {
  ::accounts::user { $username:
    shell      => '/bin/bash',
    password   => pw_hash($password, 'SHA-512', 'mysalt'),
    managehome => true,
    home_mode  => '0755',
  }

  # strings_to_leak[0]: flag in shadow file
  $shadow_flag = $strings_to_leak[0]
  exec{ 'append_flag_to_etc_shadow':
    command => "/bin/echo '$shadow_flag' >> /etc/shadow"
  }

  # strings_to_leak[1]: flag in /home/<username>/flag.txt
  ::secgen_functions::leak_files { "$username-file-leak":
    storage_directory => "/home/$username/",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => [$strings_to_leak[1]],
    owner             => $username,
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

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')


  exec { "$username-compileandsetup1":
    cwd     => "/home/$username/",
    command => "gcc -o prompt prompt.c && sudo chown $username:shadow prompt && sudo chmod 2755 prompt",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    require => Package['build-essential', 'gcc-multilib']
  }
}