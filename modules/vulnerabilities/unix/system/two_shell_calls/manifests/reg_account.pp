define two_shell_calls::reg_account($username, $password) {
  ::accounts::user { $username:
    shell      => '/bin/bash',
    password   => pw_hash($password, 'SHA-512', 'mysalt'),
    managehome => true,
    home_mode  => '0755',
  }

  file { "/home/$username/shell.c":
    owner  => $username,
    group  => $username,
    mode   => '0644',
    ensure => file,
    source => 'puppet:///modules/two_shell_calls/shell.c',
    notify => Exec[ "$username-compileandsetup" ],
  }

   exec { "$username-compileandsetup":
    cwd     => "/home/$username/",
    command => "gcc -o shell shell.c && sudo chown $username:$username shell && sudo chmod 0700 shell",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
  }
}