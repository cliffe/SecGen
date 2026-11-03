class unrealirc::install {
  
  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }

  $filename = "${unrealirc::filename}"
  $archive = "${filename}.tar.gz"
  $configure = "bash configure --with-showlistmodes --with-listen=5 --with-dpath=${unrealirc::install_path} --with-spath=${unrealirc::install_path}/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-permissions=0600 --with-fd-setsize=1024 --enable-dynamic-linking"

  # Create irc user and group
  group { $unrealirc::group:
    ensure  => present,
  }
  user { $unrealirc::user:
    ensure  => present,
    gid     => $unrealirc::group,
    require => Group[$unrealirc::group],
  }

  # Retrieve and unpack unrealirc
  file { "/tmp/${archive}":
    owner  => root,
    group  => root,
    mode   => '0775',
    ensure => present,
    replace => no,        # important: vulnerable version does not get overriden if copied to the box
    source => "puppet:///modules/unrealirc/${archive}",
    notify => Exec['extract-unrealirc'],
  }

  exec { 'extract-unrealirc':
    command => "tar -xvzf /tmp/${archive}",
    cwd     => '/tmp',
    require => File["/tmp/${archive}"],
  }

  # Move extracted directory to install path
  exec { 'unrealirc-dir':
    command => "mv `ls -d /tmp/*/ | grep -i unreal | awk '{ print \$1 }'` ${unrealirc::install_path}",
    creates => "${unrealirc::install_path}",
    require => Exec['extract-unrealirc'],
  }

  ensure_packages([
    'build-essential',
    'pkg-config',
    'gdb',
    'gcc-multilib',
    'zlib1g-dev',
    'libssl-dev',
    'libpcre2-dev',
    'libargon2-dev',
    'libsodium-dev',
    'libc-ares-dev',
    'libcurl4-openssl-dev'
  ])

  # Configure and make unrealircd, with or without ssl enabled
  if $unrealirc::use_ssl {

    exec { 'make-unrealirc':
      command => "${configure} --enable-ssl && make",
      timeout => 0,
      cwd     => "${unrealirc::install_path}",
      creates => "${unrealirc::install_path}/unreal",
      environment => [
        'CFLAGS=-fno-strict-aliasing -fno-strict-overflow -std=gnu89 -Wno-pointer-sign -fcommon'
      ],
      require => [ Package['build-essential','gcc-multilib','libssl-dev'], Exec['unrealirc-dir'] ],
    }
  } else {
    exec { 'make-unrealirc':
      command => "${configure} && make",
      timeout => 0,
      cwd     => "${unrealirc::install_path}",
      creates => "${unrealirc::install_path}/unreal",
      environment => [
        # these flags are required to get it compiled on newer systems (after Debian Buster)
        'CFLAGS=-fno-strict-aliasing -fno-strict-overflow -std=gnu89 -Wno-pointer-sign -fcommon'
      ],
      require => [Package['build-essential', 'gcc-multilib'],Exec['unrealirc-dir']],
      logoutput => true,
    }
  }

  exec { 'chown-unrealirc-dir':
    command => "chown -R ${unrealirc::user}:${unrealirc::group} ${unrealirc::install_path}",
    require => [ Group[$unrealirc::group], User[$unrealirc::user], Exec['make-unrealirc'] ],
  }

  exec { 'remove-archive':
    command => "rm -f /tmp/${archive}",
    onlyif  => "test -f /tmp/${archive}",
    require => Exec['make-unrealirc'],
  }

}
