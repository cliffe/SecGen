#
class samba_3_5_0_remote_code_execution::service{
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgeb_functions::get_parameters($::base64_inputs_file)
  $user = 'samba'
  $root_share = '/root/smbshare'
  $service_dir = '/etc/systemd/system'

  file { "${service_dir}/nmbd.service":
    source  => 'puppet:///modules/samba_3_5_0_remote_code_execution/nmbd.service',
    owner   => $user,
    mode    => '0777',
    require => File[$root_share],
    notify  => File["${service_dir}/smbd.service"],
  }
  file { "${service_dir}/smbd.service":
    source  => 'puppet:///modules/samba_3_5_0_remote_code_execution/smbd.service',
    owner   => $user,
    mode    => '0777',
    require => File["${service_dir}/nmbd.service"],
    notify  => Service['nmbd'],
  }
  service { 'nmbd':
    ensure  => running,
    enable  => true,
    require => File["${service_dir}/nmbd.service"],
    notify  => Service['smbd'],
  }
  service { 'smbd':
    ensure  => running,
    enable  => true,
    require => File["${service_dir}/smbd.service"],
  }
}
