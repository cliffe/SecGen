class gid_ifconfig::change_gid ( $file_input = [], $group = 'test', $user = 'user' ) {
  $file_input.each |$file, $group| {
  notice("file is: $file")
  notice("group is: $group")
  file { $file:
    group => "$group",
  }
}
}