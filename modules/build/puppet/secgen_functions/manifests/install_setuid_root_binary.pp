# Install function for setuid_root binaries
# -- Modules calling this function must provide a Makefile and any .c files within it's <module_name>/files directory

define secgen_functions::install_setuid_root_binary (
  $challenge_name,           # Challenge name, used for the wrapper-directory
  $source_module_name,      # Name of the module that calls this function
  $account,                 # User account (leak here if $storage_directory is not supplied)
  $flag,                    # ctf flag string
  $flag_name, # ctf flag name
  $storage_dir = '',      # Optional: Storage directory (takes precedent if supplied, e.g. nfs / smb share dir)
  $strings_to_leak = [''],  # Optional: strings to leak (could contain instructions or a message)
) {

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')

  if $account {
    $username = $account['username']

    ::accounts::user { $username:
      shell      => '/bin/bash',
      password   => pw_hash($account['password'], 'SHA-512', 'mysalt'),
      managehome => true,
      home_mode  => '0755',
    }
    $storage_directory = "/home/$username"
  } else {
    err('install: either account or storage_dir is required')
    fail
  }

  $compile_directory = "$storage_directory/tmp"
  $challenge_directory = "$storage_directory/$challenge_name"
  $modules_source = "puppet:///modules/$source_module_name"

  # Create challenge directory
  ::secgen_functions::create_directory { "create_$challenge_directory":
    path => $challenge_directory,
    notify => File["create_$compile_directory"],
  }

  # Move contents of the module's files directory into compile directory
  file { "create_$compile_directory":
    path => $compile_directory,
    ensure  => directory,
    recurse => true,
    source  => $modules_source,
  }

  # Build the binary with gcc
  exec { "gcc_$challenge_name-$compile_directory":
    cwd     => $compile_directory,
    command => "/usr/bin/make",
    require => [File["create_$compile_directory"], Package['build-essential', 'gcc-multilib']]
  }

  # Move the compiled binary into the challenge directory
  file { "$challenge_directory/$challenge_name":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '4755',
    source  => "$compile_directory/$challenge_name",
    require => Exec["gcc_$challenge_name-$compile_directory"],
  }

  # Drop the flag file on the box and set permissions
  ::secgen_functions::leak_files { "$username-file-leak":
    storage_directory => "$challenge_directory",
    leaked_filenames  => [$flag_name],
    strings_to_leak   => [$flag],
    owner             => 'root',
    mode              => '0400',
    leaked_from       => "accounts_$username",
    require           => Exec["gcc_$challenge_name-$compile_directory"],
    notify            => Exec["remove_$compile_directory"],
  }

  # Remove compile directory
  exec { "remove_$compile_directory":
    command => "/bin/rm -rf $compile_directory",
    require => [File["$challenge_directory/$challenge_name"]]
  }
}
