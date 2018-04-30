class hidden_file::install {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $challenge_name = $secgen_params['challenge_name'][0]
  $account = parsejson($secgen_params['account'][0])
  $leaked_filename = $secgen_params['leaked_filenames'][0]
  $strings_to_leak = $secgen_params['strings_to_leak']

  # Determine if storage_dir is used, if not use the account information
  if $secgen_params['storage_directory'] {
    $storage_directory = $secgen_params['storage_directory'][0]
  } else {
    $username = $account['username']
    $storage_directory = "/home/$username"

    # Create user account
    ::accounts::user { $username:
      shell      => '/bin/bash',
      password   => pw_hash($account['password'], 'SHA-512', 'mysalt'),
      managehome => true,
      home_mode  => '0755',
    }
  }

  $challenge_directory = "$storage_directory/$challenge_name"
  file { $challenge_directory: ensure => directory }

  # Drop the hidden file in the challenge directory
  ::secgen_functions::leak_files { "$challenge_name-hidden_file":
    leaked_filenames  => [".$leaked_filename"],
    storage_directory => $challenge_directory,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => "$challenge_directory-hidden_file",
  }

}
