class chkrootkit::install {
  package { 'chkrootkit':
    ensure => installed,
  }
}