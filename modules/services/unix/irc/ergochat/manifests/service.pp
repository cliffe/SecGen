class ergochat::service {
  exec { 'ergochat-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }->
  service { 'ergochat':
    enable   => true,
    ensure   => 'running',
    provider => systemd,
    require  => Package['ergochat'],
  }
}
