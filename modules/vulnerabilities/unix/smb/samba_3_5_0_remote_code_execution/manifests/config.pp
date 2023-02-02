#
class samba_3_5_0_remote_code_execution::config{
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgeb_functions::get_parameters($::base64_inputs_file)
  $user = 'samba'
  $user_home = "/home/${user}"
  $build_dir = '/opt/samba_3_5_0'
  $config_file_dir = '/usr/local/samba/lib'
  $test_dir = '/usr/local/samba/bin'
  $binary_dir = '/usr/local/samba/sbin'

  # Shares - could randomise these.
  $public_share = "/home/${user}/Public"
  $root_share = '/root/smbshare'
  $user_one_share = "/home/${user}/Bob"
  $user_two_share = "/home/${user}/John"

  # Create user shares
  file { $public_share:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0777',
    require => User[$user],
    notify  => File[$user_one_share],
  }

  file { $user_one_share:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0777',
    require => File[$public_share],
    notify  => File[$user_two_share],
  }

  file { $user_two_share:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0777',
    require => File[$user_one_share],
    notify  => File[$root_share],
  }
  file { $root_share:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0777',
    require => File[$user_two_share],
    notify  => File['/etc/systemd/system/nmbd.service'],
  }
}
