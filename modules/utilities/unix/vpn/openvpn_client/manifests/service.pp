class openvpn_client::service {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $start_on_boot = $secgen_params['start_on_boot'][0]

  if $start_on_boot == 'true' {
    service { 'openvpn-client@client':
      ensure  => running,
      enable  => true,
      require => File['/etc/openvpn/client/client.ovpn'],
    }
  } else {
    service { 'openvpn-client@client':
      ensure  => stopped,
      enable  => false,
      require => File['/etc/openvpn/client/client.ovpn'],
    }
  }
}