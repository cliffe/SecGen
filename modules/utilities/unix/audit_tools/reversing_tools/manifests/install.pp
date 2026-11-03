class reversing_tools::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
  ensure_packages(['gdb', 'git', 'ltrace', 'strace', 'valgrind', 'pax-utils', 'binwalk', 'vbindiff', 'ssdeep', 'gcc-multilib','yara'])

  # UPX: upx-ucl is not in the Debian 12 repos, so install the static UPX 4.2.4 release binary
  file { '/usr/local/bin/upx':
    ensure => file,
    source => 'puppet:///modules/reversing_tools/upx',
    mode   => '0755',
  }

  # pwntools, radare2 and GEF need Debian 12+ or Kali (older bases e.g. the Buster reversing CTFs lack the packages, gdb >= 10 and glibc >= 2.35)
  if $operatingsystem == 'Kali' or ($operatingsystem == 'Debian' and versioncmp($operatingsystemmajrelease, '12') >= 0) {

    # pwntools: packaged on both Debian 12 (4.9) and Kali
    ensure_packages(['python3-pwntools'])

    # radare2: not in the Debian 12 repos, so install the bundled upstream .deb (needs glibc >= 2.35, depends only on libc6).
    # Kali packages radare2 itself (and kali-tools-reverse-engineering may pull it in), so use apt there to avoid dpkg conflicts.
    if $operatingsystem == 'Kali' {
      ensure_packages(['radare2'])
    } else {
      file { '/opt/radare2_6.2.4_amd64.deb':
        ensure => file,
        source => 'puppet:///modules/reversing_tools/radare2_6.2.4_amd64.deb',
      }
      package { 'radare2':
        ensure   => installed,
        provider => dpkg,
        source   => '/opt/radare2_6.2.4_amd64.deb',
        require  => File['/opt/radare2_6.2.4_amd64.deb'],
      }
    }

    # GEF (2026.01, needs gdb >= 10 with python >= 3.10): run with `gef`; plain `gdb` is left unchanged for existing lab sheets.
    # /usr/local/bin precedes /usr/bin, so this also takes priority over Kali's own gef package if present.
    file { '/opt/gef':
      ensure => directory,
    }
    file { '/opt/gef/gef.py':
      ensure  => file,
      source  => 'puppet:///modules/reversing_tools/gef.py',
      mode    => '0644',
      require => File['/opt/gef'],
    }
    file { '/usr/local/bin/gef':
      ensure  => file,
      content => "#!/bin/sh\nexec gdb -q -x /opt/gef/gef.py \"\$@\"\n",
      mode    => '0755',
      require => [Package['gdb'], File['/opt/gef/gef.py']],
    }
  }

  # java (procyon was removed from kali-rolling in 2026-04)
  unless $operatingsystem == 'Kali' {
    ensure_packages(['procyon-decompiler'])
  }

  # ensure ncat is installed for testing purposes
  ensure_packages("nmap")
  case $operatingsystemrelease {
    /^(1[0-9]).*/: { # do buster stuff
      ensure_packages("ncat")
    }
  }

  # Cutter (GUI front end for radare2): deploy the bundled v1.7.2 AppImage rather than downloading it at build time.
  # The AppImage is extracted once here so it runs without FUSE; --appimage-extract-and-run would unpack
  # 240 MB into /tmp and list every file on each launch.
  file { '/opt/Cutter':
    ensure => directory,
  }
  file { '/opt/Cutter/Cutter-v1.7.2-x86_64.Linux.AppImage':
    ensure  => file,
    source  => 'puppet:///modules/reversing_tools/Cutter-v1.7.2-x86_64.Linux.AppImage',
    mode    => '0755',
    require => File['/opt/Cutter'],
  }
  exec { 'extract cutter appimage':
    command => '/opt/Cutter/Cutter-v1.7.2-x86_64.Linux.AppImage --appimage-extract',
    cwd     => '/opt/Cutter',
    creates => '/opt/Cutter/squashfs-root/AppRun',
    require => File['/opt/Cutter/Cutter-v1.7.2-x86_64.Linux.AppImage'],
  }
  # The extracted tree is root-only (0700), so open it up for the student accounts.
  exec { 'cutter readable by all users':
    command  => 'chmod -R a+rX /opt/Cutter/squashfs-root',
    onlyif   => 'find /opt/Cutter/squashfs-root \( ! -perm -a+r -o -type d ! -perm -a+x \) -print -quit | grep -q .',
    provider => shell,
    require  => Exec['extract cutter appimage'],
  }
  # The bundled Python's _ctypes links libffi.so.6, but Qt's glib loads the system libffi.so.8 first and
  # _ctypes binds to it, so Cutter aborts at "Python init" when it opens a file. Preloading libffi.so.6
  # (present on the Debian 12 KDE base) keeps those calls on the ABI _ctypes was built for.
  file { '/usr/local/bin/cutter':
    ensure  => file,
    content => "#!/bin/sh\nexport LD_PRELOAD=\"libffi.so.6\${LD_PRELOAD:+:\$LD_PRELOAD}\"\nexec /opt/Cutter/squashfs-root/AppRun \"\$@\"\n",
    mode    => '0755',
    require => Exec['cutter readable by all users'],
  }


  # TODO: Fix me
  # Install angr
  # exec { 'clone angr-dev repo':
  #   command => 'git clone https://github.com/angr/angr-dev',
  #   cwd     => '/usr/share/'
  # }
  #
  # exec { 'run angr-dev setup.sh':
  #   command   => '/bin/bash /usr/share/angr-dev/setup.sh -i -e angr-dev',
  #   cwd       => '/usr/share/angr-dev',
  #   logoutput => true,
  #   loglevel => info,
  #   timeout   => 0,
  #   require => Exec['clone angr-dev repo'],
  # }


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
