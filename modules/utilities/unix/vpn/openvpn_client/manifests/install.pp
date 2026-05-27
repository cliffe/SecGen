class openvpn_client::install {
  package { 'openvpn':
    ensure => installed,
  }
}
