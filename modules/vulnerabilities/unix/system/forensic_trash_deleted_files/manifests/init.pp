class forensic_trash_deleted_files::init {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  # filenames for the base64 encoded content (filenames themselves shouldn't be encoded)
  $leaked_base64_filenames = $secgen_parameters['leaked_base64_filenames']
  $base64_files = $secgen_parameters['binary_base64_to_leak']
  $deletion_date = strftime('%Y-%m-%dT%H:%M:%S')

  $account = parsejson($secgen_parameters['account'][0])

  if $account and $account != '' {
    $username = $account['username']
    $storage_directory = "/home/$username/.local/share/Trash/"
  } else {
    fail('The "accounts" parameter is required for forensic_trash_deleted_files.')
  }

  # create the directory tree
  exec { "$storage_directory/files/ mkdir":
     path    => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
     command => "mkdir -p $storage_directory/files/; mkdir -p $storage_directory/info/; chown $username /home/$username/.local/share/ -R",
     provider => shell,
   }
  $leaked_filenames.each |$index, $leaked_filename| {
    $string_to_leak = $strings_to_leak[$index]

    file { "$storage_directory/files/$leaked_filename":
      ensure   => present,
      owner    => $username,
      mode     => '700',
      content => $string_to_leak
    } ->
    file { "$storage_directory/info/$leaked_filename.trashinfo":
      ensure   => present,
      owner    => $username,
      mode     => '700',
      content => "[Trash Info]\nPath=/tmp/$leaked_filename\nDeletionDate=$deletion_date"
    }
  }

  $leaked_base64_filenames.each |$index, $leaked_base64_filename| {
    $base64_file = $base64_files[$index]

    file { "$storage_directory/files/$leaked_base64_filename":
      ensure   => present,
      owner    => $username,
      mode     => '700',
      content => base64('decode', $base64_file)
    } ->
    file { "$storage_directory/info/$leaked_base64_filename.trashinfo":
      ensure   => present,
      owner    => $username,
      mode     => '700',
      content => "[Trash Info]\nPath=/tmp/$leaked_base64_filename\nDeletionDate=$deletion_date"
    }
  }
}
