class distcc_exec::service{
  service { 'distcc':
    ensure => running
  }
}