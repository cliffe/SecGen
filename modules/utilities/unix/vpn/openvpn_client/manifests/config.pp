class openvpn_client::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $openvpn_pki   = parsejson($secgen_params['openvpn_pki'][0])
  $client_index  = Integer($secgen_params['client_index'][0])

  $server_ip      = $openvpn_pki['server_ip']
  $port           = $openvpn_pki['port']
  $ca_cert        = $openvpn_pki['ca_cert']
  $client         = $openvpn_pki['clients'][$client_index]
  $client_cert    = $client['client_cert']
  $client_key     = $client['client_key']

  file { '/etc/openvpn/client':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  file { '/etc/openvpn/client/client.ovpn':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('openvpn_client/client.ovpn.erb'),
    require => File['/etc/openvpn/client'],
  }
}