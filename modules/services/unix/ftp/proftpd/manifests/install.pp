class proftpd::install {
  # Debian has no package called "proftpd"; proftpd-basic pulls in proftpd-core
  # and installs /etc/proftpd, the service unit and the debconf standalone default.
  package { 'proftpd-basic':
    ensure => installed,
  }
}
