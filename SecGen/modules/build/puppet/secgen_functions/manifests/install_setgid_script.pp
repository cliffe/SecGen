# Install function for setgid binaries
# -- usage depends on utilities/accounts and utilities/xinetd so ensure they are included as requirements
#  TODO: this is probably a poor way of doing this - can we automate it?

define secgen_functions::install_setgid_script (
  $challenge_name, # Challenge name, used for the wrapper-directory
  $script_name, # Script filename
  $script_data, # Script data
  $source_module_name, # Name of the module that calls this function
  $group, # Name of group
  $account, # User account
  $flag, # ctf flag string
  $flag_name = 'flag', # ctf flag name
  $port, # Optional: script will be run on network port using xinetd
  $storage_directory     = '', # Optional: Storage directory (takes precedent if supplied, e.g. nfs / smb share dir)
  $strings_to_leak = [''], # Optional: strings to leak (could contain instructions or a message)
) {

  ensure_packages(['build-essential','gcc-multilib'])

  if $group and $group[0] {
    $grp = $group[0]
  } else {
    $grp = $challenge_name
  }

  if $account and $account[0] and $account[0] != ''{
    $acc = parsejson($account[0])
    $username = $acc['username']

    ::accounts::user { $username:
      shell      => '/bin/bash',
      password   => pw_hash($acc['password'], 'SHA-512', 'mysalt'),
      managehome => true,
      home_mode  => '0755',
    }

    $storage_dir = "/home/$username"

  } elsif $storage_directory and $storage_directory[0]{
    $storage_dir = $storage_directory[0]
    $username = 'root'
  } else {
    err('install: either account or storage_dir is required')
    fail
  }

  $challenge_directory = "$storage_dir/$challenge_name"
  $modules_source = "puppet:///modules/$source_module_name"

  group { $grp:
    ensure => present,
  }

  # Create challenge directory
  ::secgen_functions::create_directory { "create_$challenge_directory":
    path   => $challenge_directory,
    notify => File["$challenge_directory/$script_name"],
  }

  # Move the compiled binary into the challenge directory
  file { "$challenge_directory/$script_name":
    ensure  => present,
    owner   => 'root',
    group   => $grp,
    mode    => '2775',
    content => $script_data,
    require => Group[$grp],
  }

  # Drop the flag file on the box and set permissions
  ::secgen_functions::leak_files { "$username-file-leak":
    storage_directory => "$challenge_directory",
    leaked_filenames  => [$flag_name],
    strings_to_leak   => [$flag[0]],
    owner             => 'root',
    group             => $grp,
    mode              => '0440',
    leaked_from       => "$source_module_name-$module_name",
    require           => Group[$grp],
  }

  if $port and $port[0] {
    $p = $port[0]
    notice("Running $challenge_name on port $p  (dir: $challenge_directory")
    xinetd::service { "xinetd_$challenge_name":
      port         => $p,
      server       => "$challenge_directory/$script_name",
      require      => File["$challenge_directory/$script_name"],
      service_type => 'UNLISTED',
      server_args  => $challenge_directory,
      user         => $username,
      group        => $grp,
    }
  }
}
