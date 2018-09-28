class change_timestamp_all_main_times ($file_path, $file_time) {
  exec { 'change_last_write_time':
    command   => "$((ls ${file_path}).LastWriteTime = '${file_time}')",
    provider  => powershell,
  }

  exec { 'change_last_access_time':
    command   => "$((ls ${file_path}).LastAccessTime = '${file_time}')",
    provider  => powershell,
  }

  exec { 'change_creation_time':
    command   => "$((ls ${file_path}).CreationTime = '${file_time}')",
    provider  => powershell,
  }
}