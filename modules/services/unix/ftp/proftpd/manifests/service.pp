class proftpd::service {
  service { 'proftpd':
    ensure  => running,
    enable  => true,
    hasrestart  => true,
    require => File['/etc/proftpd/proftpd.conf'],
    subscribe => File['/etc/proftpd/proftpd.conf'],
  }
}