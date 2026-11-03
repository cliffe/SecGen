class bind9::service {
  service { 'bind9':
    # bind9.service is only an alias of named.service on bookworm
    name    => 'named',
    ensure  => running,
    enable  => true,
    require => Package['bind9'],
  }
}