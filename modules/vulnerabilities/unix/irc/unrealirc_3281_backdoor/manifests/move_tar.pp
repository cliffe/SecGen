class unrealirc_3281_backdoor::move_tar {
  $archive = 'Unreal3.2.8.1.tar.gz'
  $vuln_archive = 'unrealircd_3.2.8.1.vuln.tar.gz'

  file { "/tmp/$vuln_archive":
    owner  => root,
    group  => root,
    mode   => '0775',
    ensure => file,
    source => "puppet:///modules/unrealirc_3281_backdoor/$vuln_archive",
  }

  # Using mv here to avoid naming conflicts with the unrealirc::install file reosurce for /tmp/unreal3.2.8.1.tar.gz
  exec { 'move-unreal3281-vuln-tar':
    command => "/bin/mv /tmp/$vuln_archive /tmp/$archive",
  }
}