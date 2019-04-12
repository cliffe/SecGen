define secgen_functions::leak_file($leaked_filename, $storage_directory, $strings_to_leak, $owner = 'root', $group = 'root', $mode = '0660', $leaked_from = '' ) {
  if ($leaked_filename != ''){
    $path_to_leak = "$storage_directory/$leaked_filename"

    # create the directory tree, incase the file name has extra layers of directories
    exec { "$leaked_from-$path_to_leak-mkdir":
      path    => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
      command => "mkdir -p `dirname $path_to_leak`;chown $owner. `dirname $path_to_leak`",
      provider => shell,
    }

    # If the file already exists append to it, otherwise create it.
    if (defined(File[$path_to_leak])){
      notice("File with that name already defined, appending leaked strings instead...")
      exec { "$leaked_from-$path_to_leak-append":
        path    => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
        command => "echo \"\n------\n$strings_to_leak\" >> $path_to_leak",
      }
    } else {
      file { $path_to_leak:
        ensure   => present,
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        content  => template('secgen_functions/overshare.erb')
      }
    }
  }
}
