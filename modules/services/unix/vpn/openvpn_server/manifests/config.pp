class openvpn_server::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)

  $start_on_boot = $secgen_params['start_on_boot'][0]

  $openvpn_conf   = parsejson($secgen_params['openvpn_pki'][0])

  $ca_cert        = $openvpn_conf['ca_cert']
  $server_cert    = $openvpn_conf['server_cert']
  $server_key     = $openvpn_conf['server_key']
  $dh_params      = $openvpn_conf['dh_params']
  $server_ip      = $openvpn_conf['server_ip']
  $port           = $openvpn_conf['port']
  $vpn_subnet     = $openvpn_conf['vpn_subnet']
  $vpn_subnet_mask = $openvpn_conf['vpn_subnet_mask']
  $push_routes    = $openvpn_conf['push_routes']

  file { '/etc/openvpn/server':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => Package['openvpn'],
  }

  # server.conf binds to the configured 'local' address, which may not be up
  # yet when the unit starts (private network interface still configuring).
  # Allow binding to a not-yet-assigned address, and retry on failure.
  file { '/etc/sysctl.d/99-openvpn-server.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "net.ipv4.ip_nonlocal_bind = 1\n",
  }

  exec { 'openvpn-server-sysctl':
    command     => '/sbin/sysctl -w net.ipv4.ip_nonlocal_bind=1',
    refreshonly => true,
    subscribe   => File['/etc/sysctl.d/99-openvpn-server.conf'],
  }

  file { '/etc/systemd/system/openvpn-server@server.service.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['openvpn'],
  }

  file { '/etc/systemd/system/openvpn-server@server.service.d/restart.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "[Service]\nRestart=on-failure\nRestartSec=5\n",
    require => File['/etc/systemd/system/openvpn-server@server.service.d'],
  }

  exec { 'openvpn-server-daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    subscribe   => File['/etc/systemd/system/openvpn-server@server.service.d/restart.conf'],
  }

  file { '/etc/openvpn/server/ca.crt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $ca_cert,
    require => File['/etc/openvpn/server'],
  }

  file { '/etc/openvpn/server/server.crt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $server_cert,
    require => File['/etc/openvpn/server'],
  }

  file { '/etc/openvpn/server/server.key':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_key,
    require => File['/etc/openvpn/server'],
  }

  file { '/etc/openvpn/server/dh.pem':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $dh_params,
    require => File['/etc/openvpn/server'],
  }

  file { '/etc/openvpn/server/server.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('openvpn_server/server.conf.erb'),
    require => File['/etc/openvpn/server'],
  }
}