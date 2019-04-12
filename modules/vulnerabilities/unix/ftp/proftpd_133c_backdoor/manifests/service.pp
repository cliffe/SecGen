class proftpd_133c_backdoor::service {
  service { 'proftpd':
    ensure  => running,
    enable  => true,
    require => File['/etc/init.d/proftpd','/etc/proftpd/proftpd.conf'],
  }
}