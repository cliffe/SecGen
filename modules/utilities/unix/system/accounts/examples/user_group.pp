accounts::group { 'admin':
  gid => 3000,
}
accounts::group { 'sudo':
  gid => 3001,
}
accounts::group { 'sudonopw':
  gid => 3002,
}
accounts::group { 'developer':
  gid => 3003,
}
accounts::group { 'ops':
  gid => 3004,
}

accounts::user { 'jeff':
  shell    => '/bin/zsh',
  comment  => 'Jeff McCune',
  groups   => [
    'admin',
    'sudonopw',
  ],
  uid      => 1112,
  gid      => 1112,
  locked   => true,
  sshkeys  => [
    'ssh-rsa AAAA...',
    'ssh-dss AAAA...',
  ],
  password => '!!',
}
accounts::user { 'dan':
  comment => 'Dan Bode',
  uid     => '1109',
  gid     => '1109',
}
