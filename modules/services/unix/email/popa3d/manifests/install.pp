class popa3d::install{
  # Preseed debconf so the package postinst selects standalone mode (listens on
  # 110/tcp itself) rather than registering with inetd, which is not installed.
  exec { 'popa3d-preseed-standalone':
    command => '/bin/sh -c "echo popa3d popa3d/standalone boolean true | debconf-set-selections"',
    unless  => '/usr/bin/dpkg -s popa3d 2>/dev/null | grep -q "^Status: install ok installed"',
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
  }

  package { ['popa3d']:
    ensure  => 'installed',
    require => Exec['popa3d-preseed-standalone'],
  }
}
