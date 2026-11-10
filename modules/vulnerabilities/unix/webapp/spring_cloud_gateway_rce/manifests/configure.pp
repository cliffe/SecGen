# Class: spring_cloud_gateway_rce::configure
# Exposes the actuator API (the vulnerable surface) and drops the flag into the
# gateway user's home, reachable only after exploitation.
class spring_cloud_gateway_rce::configure {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port             = $secgen_parameters['port'][0]
  $user             = $secgen_parameters['unix_username'][0]
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak  = $secgen_parameters['strings_to_leak']
  $user_home        = "/home/${user}"
  $app_dir          = '/opt/scg'

  # Loaded by Spring Boot from the working directory (set in scg.service); sets
  # the listen port and exposes the gateway actuator endpoint used by the exploit.
  file { "${app_dir}/application.properties":
    ensure  => file,
    content => template('spring_cloud_gateway_rce/application.properties.erb'),
    mode    => '0644',
  }

  ::secgen_functions::leak_files { 'scg-flag-leak':
    storage_directory => $user_home,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0644',
    leaked_from       => 'spring_cloud_gateway_rce',
  }
}
