define leak_to_file::leak_file($leaked_filename, $storage_directory, $base64_file, $owner = 'root', $group = 'root', $mode = '0660', $leaked_from = '' ) {
  if ($leaked_filename != ''){
    $path_to_leak = "$storage_directory/$leaked_filename"

    # create the directory tree, incase the file name has extra layers of directories
    exec { "$leaked_from-$path_to_leak-mkdir":
      path    => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
      command => "mkdir -p `dirname $path_to_leak`;chown $owner. `dirname $path_to_leak`",
      provider => shell,
    }

    # Create file.
    file { $path_to_leak:
        require  => Exec["$leaked_from-$path_to_leak-mkdir"],
        ensure   => present,
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        content => base64('decode', $base64_file)
      }
    }
  }
