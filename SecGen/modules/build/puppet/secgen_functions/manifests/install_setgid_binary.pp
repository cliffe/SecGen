# Install function for setgid binaries
# -- Modules calling this function must provide a Makefile and any .c files within it's <module_name>/files directory

define secgen_functions::install_setgid_binary (
  $challenge_name, # Challenge name, used for the wrapper-directory
  $source_module_name, # Name of the module that calls this function
  $group, # Name of group
  $account, # User account
  $flag, # ctf flag string
  $flag_name, # ctf flag name
  $binary_path     = '', # Optional : Provide the path to a binary file that has already been compiled
  $storage_dir     = '', # Optional: Storage directory (takes precedent if supplied, e.g. nfs / smb share dir)
  $strings_to_leak = [''], # Optional: strings to leak (could contain instructions or a message)
) {

  ensure_packages(['build-essential','gcc-multilib'])

  if !$account {
    err('install: account is required for setgid challenges')
    fail
  }

  if $account {
    $username = $account['username']

  ensure_resource('parameterised_accounts::account', "parameterised_$username",
    { "username"         => $account['username'],
      "password"         => $account['password'],
      "super_user"       => str2bool($account['super_user']),
      "strings_to_leak"  => $account['strings_to_leak'],
      "leaked_filenames" => $account['leaked_filenames'], })

  if $storage_dir {
    $storage_directory = $storage_dir
  } else {
    $storage_directory = "/home/$username"
  }

  $challenge_directory = "$storage_directory/$challenge_name"
  $modules_source = "puppet:///modules/$source_module_name"

  if $binary_path == '' {
    $outer_bin_path = "/tmp/$challenge_name"
    $bin_path = "$outer_bin_path/$challenge_name"
    ::secgen_functions::compile_binary_module { "compile-$source_module_name-$challenge_name":
      source_module_name => $source_module_name,
      binary_directory   => $outer_bin_path,
      challenge_name     => $challenge_name,
      notify             => Secgen_functions::Create_directory["create_$challenge_directory"]
    }
  } else {
    $bin_path = $binary_path
  }

  ensure_resource('group', $group, { 'ensure' => 'present' })

  # Create challenge directory
  ensure_resource('file', $storage_directory, { 'ensure' => 'directory'})
  ensure_resource('file', $challenge_directory, { 'ensure' => 'directory'})

  # Move the compiled binary into the challenge directory
  file { "$challenge_directory/$challenge_name":
    ensure => present,
    owner  => 'root',
    group  => $group,
    mode   => '2771',
    source => $bin_path,
    require => File[$challenge_directory]
  }

  # Drop the flag file on the box and set permissions
  ::secgen_functions::leak_files { "$challenge_directory/$challenge_name-flag-leak":
    storage_directory => "$challenge_directory",
    leaked_filenames  => [$flag_name],
    strings_to_leak   => [$flag],
    owner             => 'root',
    group             => $group,
    mode              => '0440',
    leaked_from       => "$source_module_name/$challenge_name",
    require           => [Group[$group], File["$challenge_directory/$challenge_name"]],
  }

}
