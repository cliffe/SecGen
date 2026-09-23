class hackerbot_webclient::service {
  require hackerbot_webclient::config

  # Bind all interfaces, not just loopback: this is served on the hackerbot
  # server and fetched by a browser on a separate desktop VM over the lab's
  # private network. We bind 0.0.0.0 rather than a specific NIC IP because
  # SecGen doesn't have a reliable fact for "the private-network interface"
  # (interface names vary by distro/hypervisor, and the default ipaddress
  # fact tends to resolve to the NAT adapter, not the private network one).
  file { '/etc/systemd/system/hackerbot-webclient.service':
    ensure  => file,
    content => "[Unit]\nDescription=Hackerbot web client\nAfter=network.target\n\n[Service]\nExecStart=/usr/bin/python3 -m http.server 8080 --bind 0.0.0.0 --directory /opt/hackerbot_webclient\nRestart=on-failure\nDynamicUser=yes\nProtectSystem=strict\nProtectHome=true\nNoNewPrivileges=true\nPrivateTmp=true\n\n[Install]\nWantedBy=multi-user.target\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }->
  exec { 'hackerbot-webclient-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }->
  service { 'hackerbot-webclient':
    ensure   => running,
    enable   => true,
    provider => systemd,
  }
}
