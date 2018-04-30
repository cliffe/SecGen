class two_shell_calls::init {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  group { 'managers':
    ensure => 'present',
  }

  $accounts = $secgen_parameters['accounts']
  $accounts.each |$raw_account| {
    $account  = parsejson($raw_account)
    $username = $account['username']
    two_shell_calls::account { "two_shell_calls_$username":
      username         => $username,
      password         => $account['password'],
      strings_to_leak  => $account['strings_to_leak'],
      leaked_filenames => $account['leaked_filenames']
    }
  }
}