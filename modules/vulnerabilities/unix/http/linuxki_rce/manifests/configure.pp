# Class: linuxki_rce::configure
# LinuxKI configuration
#
class linuxki_rce::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Create user
  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }
  # The RCE lands as the Apache user (www-data), not $user: Debian's default
  # UMASK gives a new home dir 0750/0700, which would leave www-data unable
  # to even traverse into it to read the leaked flag. Open the directory up
  # so the leaked file (mode 0644 below) is actually reachable post-exploit.
  -> file { $user_home:
    ensure => directory,
    mode   => '0755',
  }

  ::secgen_functions::leak_files { 'linuxki-flag-leak':
    storage_directory => $user_home,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0644',
    leaked_from       => 'linuxki_rce',
  }
}
