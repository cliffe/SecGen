user { 'user':
  ensure => 'present',
  home => '/home/user',
}

class {'uid_bash_root::change_uid_permissions':
  file_input => {
    '/bin/bash' => '4777',
  }
}