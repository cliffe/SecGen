class setuid_nmap::init {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']


  file { '/usr/bin/nmap':
    mode => '4755',
  }

  # Leak a file containing a string/flag to /root/
  ::secgen_functions::leak_files { 'setuid_nmap-file-leak':
    storage_directory => '/root',
    leaked_filenames => $leaked_filenames,
    strings_to_leak => $strings_to_leak,
    leaked_from => "setuid_nmap",
    mode => '0600'
  }
}