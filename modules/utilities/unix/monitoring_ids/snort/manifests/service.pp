class snort::service{
  service { 'snort':
    ensure => running
  }
}