class gid_shadow::create_user ($user_name, $has_group = false, $group_name = false, $ensure = 'present') {
  user { $user_name:
    name   => $user_name,
    groups => $group_name,
    ensure => $ensure,
  }
}