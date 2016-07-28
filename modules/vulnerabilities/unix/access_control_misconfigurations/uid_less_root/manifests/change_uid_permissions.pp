class uid_less_root::change_uid_permissions ($file_input = [], $user = 'root') {
  $file_input.each |String $file, String $permission_code| {
  file { $file:
    # ensure => 'file',
    mode => "$permission_code",
    owner => $user,
  }
  notice("File {$file} permissions have been checked.")

  # exec { '/bin/sh':
  #   command => '/bin/chmod u+s /usr/bin/vi',
  #   path => '/bin/sh',
  # }
  #
  # notice("File {$file} permissions have been checked via exec.")
}
}