class readable_shadow::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_leak  = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  file { '/etc/shadow':
    ensure  => present,
    mode    => '0644',
  }

  ::secgen_functions::leak_files { 'readable-shadow-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'readable_shadow',
  }
}
