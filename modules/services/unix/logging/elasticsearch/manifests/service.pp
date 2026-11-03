class elasticsearch::service {
  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  # remove startup timeout
  file { '/etc/systemd/system/elasticsearch.service.d/':
    ensure => directory,
  }->
  file { '/etc/systemd/system/elasticsearch.service.d/startup-timeout.conf':
    ensure  => present,
    content => "[Service]\nTimeoutStartSec=180",
  }~>
  exec { 'elasticsearch daemon-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }->
  service { 'elasticsearch':
    ensure => running,
    enable => true,
  }
}
