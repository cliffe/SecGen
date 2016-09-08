class change_file_uid::change_uid_permissions ($file_input = [],$user) {
  $file_input.each |$file, $permission_code| {
  file { $file:
    mode => $permission_code,
    owner => $user,
  }
  notice("File {$file} permissions have been checked.")
}
}