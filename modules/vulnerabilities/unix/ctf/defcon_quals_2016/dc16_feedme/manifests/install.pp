class dc16_feedme::install {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $account = parsejson($secgen_params['account'][0])

  ::secgen_functions::install_setuid_root_binary { 'defcon16_amadhj':
    source_module_name     => $module_name,
    challenge_name         => $secgen_params['challenge_name'][0],
    gcc_output_binary_name => 'feedme',
    challenge_binary_name  => $secgen_params['binary_name'][0],
    account                => $account,
    flag                   => $secgen_params['flag'][0],
    storage_dir            => $secgen_params['storage_directory'],
    strings_to_leak        => $secgen_params['strings_to_leak'],
  }
}
