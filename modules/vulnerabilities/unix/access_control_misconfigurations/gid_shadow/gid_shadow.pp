class { 'gid_shadow::create_user':
  user_name => 'user',
  has_group => true,
  group_name => 'test',
  ensure => 'present',
}

user { 'user_no_group':
  name   => 'user_no_group',
  ensure => 'present',
}

class { 'gid_shadow::create_group':
  group_name => 'test',
}

class { 'gid_shadow::change_gid':
  file_input => {
    '/etc/shadow' => 'test',
  }
}

# class { gid::parse_facter_data:
#   # Facter variable name => $file_input,
# }