class popa3d::config{
  # Make sure the init script's standalone switch is on, whatever debconf did.
  exec { 'popa3d-run-standalone':
    command => '/bin/sh -c "echo RUN_STANDALONE=yes > /etc/default/popa3d"',
    unless  => '/bin/grep -q "^RUN_STANDALONE=yes" /etc/default/popa3d',
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    require => Package['popa3d'],
    notify  => Service['popa3d'],
  }

  service { 'popa3d':
    enable  => true,
    ensure  => 'running',
    require => Package['popa3d'],
  }
}
