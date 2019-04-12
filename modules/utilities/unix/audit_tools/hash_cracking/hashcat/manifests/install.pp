class hashcat::install {
  package { 'hashcat':
    ensure => installed,
  }
}