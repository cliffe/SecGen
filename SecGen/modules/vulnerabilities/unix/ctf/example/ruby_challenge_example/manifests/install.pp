class ruby_challenge_example::install {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $challenge_name = $secgen_params['challenge_name'][0]

  ::secgen_functions::install_setgid_script { $challenge_name:
    source_module_name => $module_name,
    challenge_name     => $challenge_name,
    script_name        => 'test.rb',
    script_data        => $secgen_params['script_data'][0],
    group              => $secgen_params['group'],
    account            => $secgen_params['account'],
    flag               => $secgen_params['flag'],
    port               => $secgen_params['port'],
    storage_directory  => $secgen_params['storage_directory'],
    strings_to_leak    => $secgen_params['strings_to_leak'],
  }
}
