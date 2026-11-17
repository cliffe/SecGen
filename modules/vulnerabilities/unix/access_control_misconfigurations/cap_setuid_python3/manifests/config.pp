class cap_setuid_python3::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  ensure_packages(['python3', 'libcap2-bin'])

  # The capability has to sit on the real, versioned binary (e.g. python3.11):
  # setcap refuses to follow a symlink. Resolve it at apply time so this works
  # whichever python3 minor version the base ships. Guarded by getcap so Puppet
  # only applies it when it is not already there.
  exec { 'cap_setuid_python3-setcap':
    provider => shell,
    path     => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    command  => 'setcap cap_setuid+ep "$(readlink -f /usr/bin/python3)"',
    unless   => 'getcap "$(readlink -f /usr/bin/python3)" | grep -q cap_setuid',
    require  => Package['python3', 'libcap2-bin'],
  }

  # Root-only flag, readable only after escalating
  ::secgen_functions::leak_files { 'cap-setuid-python3-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'cap-setuid-python3-flag-leak',
  }
}
