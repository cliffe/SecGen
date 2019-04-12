class unrealirc_3281_backdoor::service {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'], }

  exec { 'unrealirc_autoload':
    command => 'update-rc.d unreal defaults',
    require => File['/etc/init.d/unreal'],
  }

  service { 'unreal':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => File['/etc/init.d/unreal'],
    notify => Exec['initial_run'],
  }

  exec { 'initial_run':
    command => '/etc/init.d/unreal start'
  }
}