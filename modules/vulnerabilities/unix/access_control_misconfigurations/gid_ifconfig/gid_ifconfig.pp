class { 'gid_ifconfig::create_user':
  user_name => 'user',
  has_group => true,
  group_name => 'test',
  ensure => 'present',
}

user { 'user_no_group':
  name   => 'user_no_group',
  ensure => 'present',
}

class { 'gid_ifconfig::create_group':
  group_name => 'test',
}

class { 'gid_ifconfig::change_gid':
  file_input => {
    '/usr/sbin/service' => 'test',
  }
}

# class { gid::parse_facter_data:
#   # Facter variable name => $file_input,
# }