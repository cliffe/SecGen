class maze::install {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $challenge_name = $secgen_params['challenge_name'][0]

  if ($secgen_params['account'] and $secgen_params['account'][0]) {
    $acc = parsejson($secgen_params['account'][0])
    $username = $acc['username']
    $challenge_dir = "/home/$username/$challenge_name"
  } elsif $secgen_params['storage_directory'] and $secgen_params['storage_directory'][0] {
    $storage_dir = $secgen_params['storage_directory'][0]
    $challenge_dir = "$storage_dir/$challenge_name"
  } else {
    $challenge_dir = "/root/$challenge_name"
  }

  if $secgen_params['group'] and $secgen_params['group'][0] {
    $group = $secgen_params['group'][0]
  } else {
    $group = $challenge_name
  }

  # Move dependent maze generation script onto box
  file { 'move maze.rb':
    path   => "$challenge_dir/maze.rb",
    source => 'puppet:///modules/maze/maze.rb',
    owner  => 'root',
    group  => $group,
    mode   => '0440',
  }

  # Configure setgid wrapper script
  ::secgen_functions::install_setgid_script { $challenge_name:
    source_module_name => $module_name,
    challenge_name     => $challenge_name,
    script_name        => 'test.rb',
    script_data        => template('maze/challenge_script.rb.erb'),
    group              => $secgen_params['group'],
    account            => $secgen_params['account'],
    flag               => $secgen_params['flag'],
    port               => $secgen_params['port'],
    storage_directory  => $secgen_params['storage_directory'],
    strings_to_leak    => $secgen_params['strings_to_leak'],
  }


}