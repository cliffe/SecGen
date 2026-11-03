class hackerbot::service{
  require hackerbot::config

  file { '/etc/systemd/system/hackerbot.service':
    ensure => 'link',
    target => '/opt/hackerbot/hackerbot.service',
  }~>
  exec { 'hackerbot-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }->
  service { 'hackerbot':
    ensure   => running,
    provider => systemd,
    enable   => true,
  }
}
