class chroot_debootstrap::install {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $chroot_dir = $secgen_parameters['chroot_dir'][0]

  ensure_packages(['debootstrap', 'libc-bin'])

  file { "$chroot_dir":
    ensure => 'directory',
  } ->

  exec { "debootstrap bookworm $chroot_dir":
    command => "debootstrap bookworm $chroot_dir http://deb.debian.org/debian/",
    environment => ["DEBIAN_FRONTEND=noninteractive"],
    cwd     => '/var/tmp',
    provider     => 'shell',
    creates => "$chroot_dir/etc",
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
    logoutput => 'true',
    timeout     => 1800, # 30 mins timeout
  } ->

  exec { "chroot ncat install $chroot_dir":
    command => "chroot $chroot_dir /usr/bin/apt-get install ncat -y",
    environment => ["DEBIAN_FRONTEND=noninteractive"],
    cwd     => '/var/tmp',
    provider     => 'shell',
    creates => "$chroot_dir/usr/bin/ncat",
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
    logoutput => 'true',
    timeout     => 1800, # 30 mins timeout
  } ->

  file_line { "${chroot_dir}_chroot_proc":
    path => '/etc/fstab',
    line => "proc $chroot_dir/proc proc defaults 0 0",
  }
}
