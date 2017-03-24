class setuid_nmap::init {
  $json_inputs = base64('decode', $::base64_inputs)
  $secgen_parameters = parsejson($json_inputs)
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
  }
}