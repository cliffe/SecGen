class proftpd_133c_backdoor::install {

  # Install ProFTPd 1.3.3c backdoored version from source tar

  file { '/usr/local/src/proftpd-1.3.3c.tar.gz':
    owner  => root,
    group  => root,
    mode   => '0775',
    ensure => file,
    source => 'puppet:///modules/proftpd_133c_backdoor/proftpd-1.3.3c.tar.gz',
    notify => Exec['unpack'],
  }

  exec { 'unpack':
    cwd     => '/usr/local/src',
    command => 'tar -xzvf proftpd-1.3.3c.tar.gz',
    creates => '/usr/local/src/backdoored_proftpd-1.3.3c/',
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    notify  => Exec['install_proftpd-1.3.3c'],
  }

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')

  exec { 'install_proftpd-1.3.3c':
    cwd     => '/usr/local/src/backdoored_proftpd-1.3.3c/',
    command => '/usr/local/src/backdoored_proftpd-1.3.3c/configure', #--prefix=/usr/local/
    notify  => Exec['make_proftpd-1.3.3c'],
    require => Package['build-essential', 'gcc-multilib'],
  }

  exec { 'make_proftpd-1.3.3c':
    require     => Exec['install_proftpd-1.3.3c'],
    cwd         => '/usr/local/src/backdoored_proftpd-1.3.3c/',
    command     => '/usr/bin/make',
    notify      => Exec['make_install_proftpd-1.3.3c'],
  }

  exec { 'make_install_proftpd-1.3.3c':
    require     => Exec['install_proftpd-1.3.3c'],
    cwd         => '/usr/local/src/backdoored_proftpd-1.3.3c/',
    command     => '/usr/bin/make install',
    notify      => File['/etc/init.d/proftpd'],
  }

  # ProFTPd init.d service installation

  file { '/etc/init.d/proftpd':
    require => Exec['make_install_proftpd-1.3.3c'],
    path    => '/etc/init.d/proftpd',
    owner   => root,
    group   => root,
    mode    => '0755',
    ensure  => file,
    source  => 'puppet:///modules/proftpd_133c_backdoor/proftpd.init.d',
  }

  # Required log and config files/directories

  file { ['/etc/proftpd', '/var/log/proftpd', '/var/log/proftpd/xferlog', '/etc/proftpd/conf.d/']:
    ensure => directory,
  }

  file { [ '/etc/proftpd/modules.conf', '/var/log/proftpd/proftpd.log']:
    ensure => file,
  }

  # Cleanup
  exec { 'directory-cleanup':
    command => '/bin/rm /usr/local/src/* -rf',
  }
}