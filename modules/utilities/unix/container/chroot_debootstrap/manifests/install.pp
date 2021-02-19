class chroot_debootstrap::install {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $chroot_dir = $secgen_parameters['chroot_dir'][0]

  package { ['debootstrap', 'libc-bin']:
    ensure => 'installed',
  } ->

  file { "$chroot_dir":
    ensure => 'directory',
  } ->

  exec { "sudo -E debootstrap stretch $chroot_dir http://deb.debian.org/debian/":
    cwd     => '/var/tmp',
    provider     => 'shell',
    creates => "$chroot_dir/etc",
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
  } ->

  exec { "sudo -E chroot $chroot_dir /usr/bin/apt-get install nmap -y":
    cwd     => '/var/tmp',
    provider     => 'shell',
    creates => "$chroot_dir/usr/bin/ncat",
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
    logoutput => 'true',
  } ->

  file_line { "${chroot_dir}_chroot_proc":
    path => '/etc/fstab',
    line => "proc $chroot_dir/proc proc defaults 0 0",
  }
}
