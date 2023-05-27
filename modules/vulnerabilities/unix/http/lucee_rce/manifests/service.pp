# Class: lucee_rce::service
# Service behaviour
#
class lucee_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]

  file { '/etc/systemd/system/lucee.service':
    content => template('lucee_rce/lucee.service.erb'),
    owner   => 'root',
    mode    => '0777',
  }

  service { 'lucee':
    ensure => 'running',
    enable => 'true',
  }
}
