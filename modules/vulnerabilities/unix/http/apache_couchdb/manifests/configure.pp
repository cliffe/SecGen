class apache_couchdb::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $database = 'couchdb'
  $user = $secgen_parameters['unix_username'][0]
  $password = $secgen_parameters['used_password'][0]
  $jsondb = 'sampledata' ##TODO secgen
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $user_home = "/home/${user}"

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ::secgen_functions::leak_files { 'couchdb-flag-leak':
    storage_directory => $user_home,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0644',
    leaked_from       => 'apache_couchdb',
  }
}
