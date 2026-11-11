# Class: spring_cloud_gateway_rce::service
# Runs the gateway as a systemd service under the non-root gateway user.
class spring_cloud_gateway_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]

  file { '/etc/systemd/system/scg.service':
    content => template('spring_cloud_gateway_rce/scg.service.erb'),
    owner   => 'root',
    mode    => '0644',
    notify  => Exec['scg-systemd-reload'],
  }
  # systemd must re-read unit files before the freshly dropped unit can start.
  -> exec { 'scg-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    refreshonly => true,
  }
  -> service { 'scg':
    ensure   => 'running',
    enable   => 'true',
    provider => systemd,
  }
}
