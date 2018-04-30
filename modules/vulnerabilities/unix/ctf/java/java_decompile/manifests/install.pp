class java_decompile::install {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $account = parsejson($secgen_params['account'][0])
  $challenge_name = $secgen_params['challenge_name'][0]
  $username = $account['username']
  $strings_to_leak = $secgen_params['strings_to_leak']
  $flag = $secgen_params['flag'][0]
  $password = $secgen_params['password'][0]

  # Determine if storage_dir is used, if not use the account information
  if $secgen_params['storage_directory'] {
    $storage_directory = $secgen_params['storage_directory'][0]
    $leaked_filenames = ["$challenge_name-instructions"]
  } else {
    $storage_directory = "/home/$username"
    $leaked_filenames = $account['leaked_filenames']

    # Create user account
    ::accounts::user { $username:
      shell      => '/bin/bash',
      password   => pw_hash($account['password'], 'SHA-512', 'mysalt'),
      managehome => true,
      home_mode  => '0755',
    }
  }

  $compile_directory = "$storage_directory/tmp"
  $challenge_directory = "$storage_directory/$challenge_name"

  file { $compile_directory: ensure => directory }
  file { $challenge_directory: ensure => directory }

  # Drop the message in the home directory
  ::secgen_functions::leak_files { "$challenge_name-instructions":
    storage_directory => $challenge_directory,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => "java_decompile_instructions",
  }

  # Run the template to generate a .java file
  file { "$compile_directory/Crackme.java":
    ensure  => file,
    content => template('java_decompile/Crackme.java.erb'),
    require => File[$compile_directory],
  }

  # Compile the java file into a .class file
  exec { "javac_$compile_directory-Crackme.java":
    cwd     => $compile_directory,
    command => "/usr/bin/javac Crackme.java",
    require => File["$compile_directory/Crackme.java"]
  }

  # Move the files into a challenge directory
  file { "$challenge_directory/$challenge_name.class":
    source => "$compile_directory/Crackme.class",
    require => Exec["javac_$compile_directory-Crackme.java"],
  }

  # Remove compile directory
  exec { 'remove_compile_directory':
    command => "/bin/rm $compile_directory -rf",
    # require => File["$challenge_directory/$challenge_name.class"],
  }
}
