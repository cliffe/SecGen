class bind9::install {
  package { 'bind9':
    ensure => installed,
  }
}