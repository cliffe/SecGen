class {'uid_less_root::change_uid_permissions':
  user => 'root',
  file_input => {
    '/bin/less' => '4777',
    '/usr/bin/less' => '4777',
  },
}