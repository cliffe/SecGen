class ssh_leaked_keys::init {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  $accounts = $secgen_parameters['accounts']
  $accounts.each |$raw_account| {
    $account = parsejson($raw_account)
    $username = $account['username']
    ssh_leaked_keys::account { "ssh_leaked_keys_$username":
      username         => $username,
      password         => $account['password'],
      strings_to_leak  => $strings_to_leak,
      leaked_filenames => $account['leaked_filenames'],
      ssh_key_pair     => parsejson($secgen_parameters['ssh_key_pair'][0]),
    }
  }
}