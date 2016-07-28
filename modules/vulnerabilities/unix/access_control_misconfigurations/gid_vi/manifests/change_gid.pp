class gid_vi::change_gid ( $file_input = [], $group = 'test', $user = 'user' ) {

  group { $group:
    name   => $group,
    ensure => 'present',
  }

  user { $user:
    name => $user,
    groups => $group,
    ensure => 'present',
  }

  user { 'user_non_group':
    ensure => 'present',
  }

  $file_input.each |$file, $group| {
  # if (($index % 2) == 0) {
  #   # Value is odd
  # $file = regsubst($file_input[$index],'"|\'','\1','G')
  # $group = regsubst($file_input[$index + 1],'"|\'','\1','G')

  notice("file is: $file")
  notice("group is: $group")
  file { $file:
    # ensure => 'file',
    # mode => "$permission_code",
    group => "$group",
  }
  # } else {
  #   # Value is even so do nothing
  # }
}
}


#   $file_input.each |$index, $value| {
#   if (($index % 2) == 0) {
#     # Value is odd
#     $file = regsubst($file_input[$index],'"|\'','\1','G')
#     $group = regsubst($file_input[$index + 1],'"|\'','\1','G')
#
#     notice("file is: $file")
#     notice("group is: $group")
#     file { $file:
#       # ensure => 'file',
#       # mode => "$permission_code",
#       group => "$group",
#     }
#   } else {
#     # Value is even so do nothing
#   }
# }


# $file_input.each |String $file, String $permission_code| {
# file { $file:
#   # ensure => 'file',
#   # mode => "$permission_code",
#   group => "test",
# }
# notice("File {$file} permissions have been checked.")
#
# # exec { '/bin/sh':
# #   command => '/bin/chmod u+s /usr/bin/vi',
# #   path => '/bin/sh',
# # }
# #
# # notice("File {$file} permissions have been checked via exec.")

# }