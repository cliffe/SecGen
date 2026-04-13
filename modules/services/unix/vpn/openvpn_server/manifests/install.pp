class openvpn_server::install {
  package { 'openvpn':
    ensure => installed,
  }
}