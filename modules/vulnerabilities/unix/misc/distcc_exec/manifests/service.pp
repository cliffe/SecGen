class distcc_exec::service{
  # distccd's packaged SysV wrapper only orders the daemon After=network.target,
  # which is reached before the isolated lab interface has finished coming up.
  # On a fresh boot the daemon can therefore be listening on its high port while
  # the target's own route to the attacker subnet is not yet established, so the
  # first contact (and the exploit's reverse payload) can race the network and
  # get no reply, while an immediate retry seconds later succeeds. Order distccd
  # After=network-online.target (and pull that target in) so it only starts once
  # the network is fully up, making it answer dependably on first contact. This
  # changes nothing about how the service behaves once up, so other scenarios
  # that use this module are unaffected.
  file { '/etc/systemd/system/distcc.service.d':
    ensure => directory,
    mode   => '0755',
  }->
  file { '/etc/systemd/system/distcc.service.d/network-online.conf':
    ensure  => present,
    mode    => '0644',
    content => "[Unit]\nWants=network-online.target\nAfter=network-online.target\n",
    notify  => Exec['distcc-systemd-reload'],
  }

  exec { 'distcc-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }->
  service { 'distcc':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/systemd/system/distcc.service.d/network-online.conf'],
  }
}
