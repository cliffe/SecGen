class bind9::service {
  service { 'bind9':
    ensure  => running,
    enable  => true,
    require => Package['bind9'],
  }
}