# Service management for MalTrail
class maltrail_rce::service {
  require maltrail_rce::config

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  file { '/etc/systemd/system/maltrail.service':
    content => template('maltrail_rce/maltrail.service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec { 'daemon-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    subscribe   => File['/etc/systemd/system/maltrail.service'],
  }

  service { 'maltrail':
    ensure  => running,
    enable  => true,
    require => [File['/etc/systemd/system/maltrail.service'], Exec['daemon-reload']],
  }
}
