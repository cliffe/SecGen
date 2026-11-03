class disable_aslr::config {

  file { '/etc/sysctl.d/01-disable-aslr.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "kernel.randomize_va_space = 0\n",
    notify  => Exec['apply_disable_aslr'],
  }

  # Apply immediately: the file alone only takes effect at the next boot.
  # Also runs if the value drifts, so the runtime state matches the file.
  exec { 'apply_disable_aslr':
    command => '/sbin/sysctl -w kernel.randomize_va_space=0',
    unless  => '/bin/sh -c "[ \"$(/sbin/sysctl -n kernel.randomize_va_space)\" = 0 ]"',
    path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
    require => File['/etc/sysctl.d/01-disable-aslr.conf'],
  }
}
