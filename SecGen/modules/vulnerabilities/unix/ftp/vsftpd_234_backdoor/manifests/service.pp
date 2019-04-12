class vsftpd_234_backdoor::service {
  service { 'vsftpd':
    ensure  => running,
    enable  => true,
    require => File['/etc/init.d/vsftpd'],
  }
}