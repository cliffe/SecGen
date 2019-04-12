class {'uid_vi_root::change_uid_permissions':
  file_input => {
    '/usr/bin/vi' => '4777',
    '/etc/alternatives/vi' => '4777',
    '/usr/bin/vim.tiny'    => '4777',
  }
}