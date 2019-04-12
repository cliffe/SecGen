class uid_less_root::change_uid_permissions ($file_input = [], $user = 'root') {
  $file_input.each |$file, $permission_code| {
    file { $file:
      mode => $permission_code,
      owner => $user,
    }
    notice("File {$file} permissions have been checked.")
  }
}