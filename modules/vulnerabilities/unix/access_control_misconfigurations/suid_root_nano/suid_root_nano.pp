class { 'suid_root_nano::change_uid_permissions':
  file_input => {
    '/bin/nano' => '4777',
    '/usr/bin/nano' => '4777',
  }
}