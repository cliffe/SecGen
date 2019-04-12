class smbclient::install {
  package { 'smbclient':
    ensure => 'installed',
  }
}