class popa3d::config{
  service { 'popa3d':
    enable => true,
    ensure => 'running',
  }
}
