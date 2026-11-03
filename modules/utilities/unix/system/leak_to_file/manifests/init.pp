class leak_to_file::init {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $leaked_filename = $secgen_parameters['leaked_filename'][0]
  $base64_file = $secgen_parameters['base64_file'][0]

  $raw_account = $secgen_parameters['account'] ? {
    undef   => '',
    default => $secgen_parameters['account'][0],
  }

  if $raw_account and $raw_account != '' {
    # account inputs arrive as JSON strings (as in parameterised_accounts)
    $account = $raw_account ? {
      String  => parsejson($raw_account),
      default => $raw_account,
    }
    $username = $account['username']
    $storage_directory = "/home/$username/"
  } else {
    $username = 'root'
    $storage_directory = $secgen_parameters['storage_directory'][0]
  }

  leak_to_file::leak_file { "${storage_directory}/${leaked_filename}":
    leaked_filename => $leaked_filename,
    storage_directory => $storage_directory,
    base64_file => $base64_file,
    owner => $username,
    group => $username,
  }
}
