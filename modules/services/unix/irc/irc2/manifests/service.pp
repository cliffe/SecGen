class irc2::service {
  # The packaged unit runs /usr/sbin/ircd as Type=simple, but ircd forks into
  # the background by default, so systemd sees the main process exit and
  # reports the unit inactive. -t keeps ircd in the foreground. -s stops ircd
  # starting the external iauth helper, whose packaged config (required +
  # rfc931) holds clients at the 020 "Please wait" notice.
  #
  # ircd resolves every client's address with its own resolver, which ignores
  # /etc/hosts and RES_OPTIONS and waits ~30s per lookup when the system
  # nameserver is unreachable (as on an isolated lab network), holding the
  # client at 020 until then. ircd gets a private resolv.conf pointing at a
  # dnsmasq on 127.0.0.2 that answers NXDOMAIN at once, so clients register
  # by IP immediately. The system resolver is left alone.
  ensure_packages(['dnsmasq-base'])

  file { '/etc/ircd/resolv.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "nameserver 127.0.0.2\n",
    require => Package['ircd-irc2'],
  }

  file { '/etc/systemd/system/ircd-irc2-dns.service':
    ensure  => file,
    mode    => '0644',
    content => "[Unit]\nDescription=Local NXDOMAIN resolver for ircd-irc2\nBefore=ircd-irc2.service\n\n[Service]\nExecStart=/usr/sbin/dnsmasq --keep-in-foreground --conf-file=/dev/null --pid-file=/run/ircd-irc2-dns.pid --no-resolv --no-hosts --no-poll --bogus-priv --address=/#/ --listen-address=127.0.0.2 --bind-interfaces --port=53 --user=nobody --group=nogroup\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n",
    require => Package['dnsmasq-base'],
    notify  => Exec['irc2-systemd-reload'],
  }

  file { '/etc/systemd/system/ircd-irc2.service.d':
    ensure  => directory,
    require => Package['ircd-irc2'],
  }->
  file { '/etc/systemd/system/ircd-irc2.service.d/foreground.conf':
    ensure  => present,
    content => "[Unit]\nRequires=ircd-irc2-dns.service\nAfter=ircd-irc2-dns.service\n\n[Service]\nExecStart=\nExecStart=/usr/sbin/ircd -s -t\nBindReadOnlyPaths=/etc/ircd/resolv.conf:/etc/resolv.conf\n",
    require => File['/etc/ircd/resolv.conf'],
    notify  => Exec['irc2-systemd-reload'],
  }

  exec { 'irc2-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }->
  service { 'ircd-irc2-dns':
    enable   => true,
    ensure   => 'running',
    provider => systemd,
  }->
  service { 'ircd-irc2':
    enable    => true,
    ensure    => 'running',
    provider  => systemd,
    subscribe => File['/etc/systemd/system/ircd-irc2.service.d/foreground.conf'],
  }
}
