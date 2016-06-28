class { misconfig_uid::parse_facter_data: }

# class {'misconfig_uid::change_uid':
#   user => 'root',
#   file_input => {
#     '/usr/bin/vi' => '4777',
#     '/etc/alternatives/vi' => '4777',
#     '/usr/bin/vim.tiny'    => '4777',
#   },
# }