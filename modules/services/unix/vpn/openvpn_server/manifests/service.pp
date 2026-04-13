class openvpn_server::service {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $start_on_boot = $secgen_params['start_on_boot'][0]

  if $start_on_boot == 'true' {
    service { 'openvpn-server@server':
      ensure  => running,
      enable  => true,
      require => File['/etc/openvpn/server/server.conf'],
    }
  } else {
    service { 'openvpn-server@server':
      ensure  => stopped,
      enable  => false,
      require => File['/etc/openvpn/server/server.conf'],
    }
  }
}