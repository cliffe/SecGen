class nmap::install {
  package { 'nmap':
    ensure => installed,
  }
}