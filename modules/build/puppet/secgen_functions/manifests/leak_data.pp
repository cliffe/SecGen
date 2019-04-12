define secgen_functions::leak_data (
  $data_to_leak = [],
  $storage_directory,
  $owner        = 'root',
  $group        = 'root',
  $mode         = '0660',
  $leaked_from  = ''
) {

  $data_to_leak.each |$i, $data_element| {
    if "secgen_leaked_data" in $data_element {
      $secgen_leaked_data = parsejson($data_element)

      $data = $secgen_leaked_data['secgen_leaked_data']['data']
      $filename = $secgen_leaked_data['secgen_leaked_data']['filename']
      $ext = $secgen_leaked_data['secgen_leaked_data']['ext']
      $subdirectory = $secgen_leaked_data['secgen_leaked_data']['subdirectory']

      if $ext != '' {
        $full_filename = "$filename.$ext"
      } else {
        $full_filename = $filename
      }

      $storage_dir = "$storage_directory/$subdirectory"
      $path_to_leak = "$storage_dir/$full_filename"
      $leaked_file_resource = "$leaked_from-$path_to_leak"

      unless $subdirectory == '' {
        ::secgen_functions::create_directory { "create-$storage_dir-$i":
          res    => "create-$storage_dir-$i",
          path   => $storage_dir,
          notify => File[$path_to_leak]
        }
      }

      file { $path_to_leak:
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        content => base64('decode', $data)
      }

    } else {
      fail("Invalid data!")
    }
  }

}
