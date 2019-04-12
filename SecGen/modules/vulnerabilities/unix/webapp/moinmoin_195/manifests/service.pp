class moinmoin_195::service {
  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Exec['permissions-moinmoin'],
  }
}