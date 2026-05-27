class handy_networking_tools::install{

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $disable_ntp = downcase($secgen_parameters['disable_ntp'][0])

  if $disable_ntp == 'true'{
    service { 'systemd-timesyncd':
      ensure => stopped,
      enable => false,
    }
  }

  ensure_packages([
    'resolvconf',
    'dnsutils',
    'openssl',
    'openvpn',
    'tcpdump',
    'curl',
    'traceroute',
    'whois',
    'net-tools',
  ])
}