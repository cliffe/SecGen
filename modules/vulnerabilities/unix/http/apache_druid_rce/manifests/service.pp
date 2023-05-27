# Class: apache_druid_rce::service
# Service behaviour
#
class apache_druid_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]

  file { '/etc/systemd/system/druid.service':
    content => template('apache_druid_rce/druid.service.erb'),
    owner   => 'root',
    mode    => '0755',
  }
  -> service { 'druid':
    ensure => running,
    enable => true,
  }
}
