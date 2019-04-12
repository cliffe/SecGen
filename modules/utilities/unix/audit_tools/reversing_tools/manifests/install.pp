class reversing_tools::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
  ensure_packages(['gdb', 'git', 'ltrace', 'strace', 'pax-utils', 'binwalk' ])

  # Install Radare2

  # file { '/opt/radare2-2.7.0.tar.gz':
  #   ensure => present,
  #   source => 'puppet:///modules/reversing_tools/radare2-2.7.0.tar.gz',
  # }
  #
  # exec { 'unpack r2':
  #   cwd => '/opt/',
  #   command => 'tar -xzvf radare2-2.7.0.tar.gz',
  # }
  #
  # exec { 'configure r2':
  #   cwd => '/opt/radare2-2.7.0/',
  #   command => '/bin/bash ./configure --prefix=/usr',
  # }
  #
  # exec { 'make r2':
  #   cwd => '/opt/radare2-2.7.0/',
  #   command => '/usr/bin/make -j8',
  # }
  #
  # exec { 'make install r2':
  #   cwd => '/opt/radare2-2.7.0/',
  #   command => 'make install',
  # }
  #
  # # Install Cutter
  # $cutter_dir = '/opt/Cutter'
  # $cutter_appimage_url = 'https://github.com/radareorg/cutter/releases/download/v1.7.2/Cutter-v1.7.2-x86_64.Linux.AppImage'
  # $cutter_filename = 'Cutter-v1.7.2-x86_64.Linux.AppImage'
  # file { $cutter_dir:
  #   ensure => directory,
  # }
  #
  # # Download image
  # exec { 'download cutter appimage':
  #   command => "/usr/bin/wget -q $cutter_appimage_url -O $cutter_dir/$cutter_filename",
  #   cwd => $cutter_dir,
  #   require => File[$cutter_dir],
  # }
  #
  # exec { 'chmod cutter':
  #   command => "/bin/chmod +x $cutter_dir/$cutter_filename",
  #   cwd => $cutter_dir,
  #   require => Exec['download cutter appimage'],
  # }
  #
  # exec { 'install cutter':
  #   command => "/usr/bin/install $cutter_dir/$cutter_filename /usr/bin/cutter",
  #   cwd => $cutter_dir,
  #   require => Exec['download cutter appimage'],
  # }

  # Install angr
  exec { 'clone angr-dev repo':
    command => 'git clone https://github.com/angr/angr-dev',
    cwd     => '/usr/share/'
  }

  exec { 'run angr-dev setup.sh':
    command   => '/bin/bash /usr/share/angr-dev/setup.sh -i -e angr-dev',
    cwd       => '/usr/share/angr-dev',
    logoutput => true,
    loglevel => info,
    timeout   => 0,
    require => Exec['clone angr-dev repo'],
  }


  # TODO: Test all this!
  #
  # if $accounts {
  #   $accounts.each |$raw_account| {
  #     $account = parsejson($raw_account)
  #     $username = $account['username']
  #     notice ("Enabling angr virtualenv for account: [$username]")
  #
  #     $home_dir = "/home/$username"
  #
  #     exec { "$username-angr-workon-env-append":
  #       command => "echo \"export WORKON_ENV=/.virtualenvs\" >> $home_dir/.bashrc",
  #       require => Exec['run angr-dev setup.sh'],
  #     }
  #
  #     file { "$home_dir/angr-instructions.txt":
  #       content => 'The angr binary-analysis framework has been installed within a python virtual environment.
  #
  #       Run `workon angr-dev` to use the virtualenv.
  #
  #       If this fails, try adding adding the environment variable first by running `export WORKON_DEV=/.virtualenvs`'
  #     }
  #   }
  # }

  # Install packer detection tool? (e.g. Detect It Easy) (TODO)
  # Install AFL?(TODO)
  # Install Driller?(TODO)
  # Install Qira? (TODO)
}