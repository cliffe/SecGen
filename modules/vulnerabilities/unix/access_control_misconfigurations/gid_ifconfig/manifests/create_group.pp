class gid_ifconfig::create_group ( $group_name ) {
  group { $group_name:
    name   => $group_name,
    ensure => 'present',
  }
}