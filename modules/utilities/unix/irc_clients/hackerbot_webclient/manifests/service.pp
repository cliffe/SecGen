class hackerbot_webclient::service {
  require hackerbot_webclient::config

  # Loopback only: this page is meant to be opened by a browser running on
  # this same desktop, not served across the lab network.
  file { '/etc/systemd/system/hackerbot-webclient.service':
    ensure  => file,
    content => "[Unit]\nDescription=Hackerbot web client\nAfter=network.target\n\n[Service]\nExecStart=/usr/bin/python3 -m http.server 8080 --bind 127.0.0.1 --directory /opt/hackerbot_webclient\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n",
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
