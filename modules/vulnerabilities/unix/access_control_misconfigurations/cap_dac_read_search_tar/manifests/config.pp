class cap_dac_read_search_tar::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  ensure_packages('libcap2-bin')

  # The misconfiguration: tar may bypass file read and directory search
  # permission checks, so any user can archive (and so read) root-only files.
  # The unless guard keeps this idempotent.
  exec { 'tar-setcap-cap_dac_read_search':
    command => 'setcap cap_dac_read_search+ep /usr/bin/tar',
    unless  => 'getcap /usr/bin/tar | grep -q cap_dac_read_search',
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => Package['libcap2-bin'],
  }

  ::secgen_functions::leak_files { 'cap-dac-read-search-tar-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'cap-dac-read-search-tar-flag-leak',
  }
}
