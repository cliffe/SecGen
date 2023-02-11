# Class: tikiwiki_cal_rce::configure
# Configure additional behaviour and flags
#
class tikiwiki_cal_rce::configure {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $known_username = $secgen_parameters['known_username'][0]
  $known_password = $secgen_parameters['known_password'][0]
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $web_pre_leak_filename = $secgen_parameters['web_pre_leak_filename'][0]

  ::secgen_functions::leak_files { 'tikiwiki-flag-leak':
    storage_directory => '/var/www/tiki-14.1/',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'www-data',
    mode              => '0750',
    leaked_from       => 'tikiwiki_cal_rce',
  }
}
