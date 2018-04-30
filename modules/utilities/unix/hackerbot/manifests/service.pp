class hackerbot::service{
  require hackerbot::config

  file { '/etc/systemd/system/hackerbot.service':
    ensure => 'link',
    target => '/opt/hackerbot/hackerbot.service',
  }->
  service { 'NetworkManager':
    ensure   => stopped,
    enable   => false,
  }->
  service { 'hackerbot':
    ensure   => running,
    enable   => true,
  }~>
  # reload services (networking needs to be reloaded on the kali virtualbox vm)
  exec { 'hackerbot-systemd-reload':
    command     => 'systemctl daemon-reload; service networking restart; service hackerbot restart',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }

}
