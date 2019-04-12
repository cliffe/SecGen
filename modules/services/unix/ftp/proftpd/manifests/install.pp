class proftpd::install {
  package { 'proftpd':
    ensure => installed,
    name => 'proftpd',
  }
}