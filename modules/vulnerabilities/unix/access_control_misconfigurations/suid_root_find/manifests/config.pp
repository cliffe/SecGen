class suid_root_find::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  # On bookworm /bin is a symlink to /usr/bin, so /usr/bin/find is the real
  # binary (findutils). Set the mode on it directly, not on a symlink.
  file { '/usr/bin/find':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '4755',
  }

  ::secgen_functions::leak_files { 'suid-root-find-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'suid-root-find-flag-leak',
  }
}
