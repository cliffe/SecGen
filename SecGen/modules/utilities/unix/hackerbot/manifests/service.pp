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
  }
}
