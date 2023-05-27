# Class: lucee_rce::configure
# Configuration for lucee with secgen
#
class lucee_rce::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  file { '/usr/local/src/lucee-express-5.3.7.43.zip':
    ensure => absent
  }

  ::secgen_functions::leak_files { 'lucee-flag-leak':
    storage_directory => $user_home,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0644',
    leaked_from       => 'lucee_rce',
  }
}
