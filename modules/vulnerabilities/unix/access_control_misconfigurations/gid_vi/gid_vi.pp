class { gid_vi::change_gid:
  file_input => {
    '/usr/bin/vi'          => 'test',
    '/etc/alternatives/vi' => 'test',
    '/usr/bin/vim.tiny'    => 'test',
  }
}

# class { gid_vi::parse_facter_data:
#   # Facter variable name => $file_input,
# }