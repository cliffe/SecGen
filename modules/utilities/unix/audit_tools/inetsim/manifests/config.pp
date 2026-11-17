# Binds every INetSim service to all interfaces (so traffic redirected to this host is answered)
# and points the fake DNS answers at dns_default_ip.
class inetsim::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $dns_default_ip = $secgen_parameters['dns_default_ip'][0]

  # The shipped config has these settings commented out ('#service_bind_address 10.10.10.1').
  file_line { 'inetsim service_bind_address':
    path    => '/etc/inetsim/inetsim.conf',
    line    => 'service_bind_address 0.0.0.0',
    match   => '^#?service_bind_address\s',
    require => Class['inetsim::install'],
  }

  file_line { 'inetsim dns_default_ip':
    path    => '/etc/inetsim/inetsim.conf',
    line    => "dns_default_ip ${dns_default_ip}",
    match   => '^#?dns_default_ip\s',
    require => Class['inetsim::install'],
  }
}
