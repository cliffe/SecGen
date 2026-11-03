# amap is not packaged in Debian 12 (last Debian release was sarge), so build
# the upstream THC release 5.4 from the bundled tarball.
# sha256 a75ea58de75034de6b10b0de0065ec88e32f9e9af11c7d69edbffc4da9a5b059
# source: https://github.com/vanhauser-thc/THC-Archive/tree/master/Tools
class amap::install {
  $build_dir = '/opt/amap-build'

  ensure_packages(['build-essential', 'libssl-dev', 'libpcre3-dev'])

  file { $build_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${build_dir}/amap-5.4.tar.gz":
    ensure  => file,
    source  => 'puppet:///modules/amap/amap-5.4.tar.gz',
    require => File[$build_dir],
  }

  exec { 'extract amap':
    command => 'tar xzf amap-5.4.tar.gz',
    path    => ['/usr/bin', '/bin'],
    cwd     => $build_dir,
    creates => "${build_dir}/amap-5.4/configure",
    require => File["${build_dir}/amap-5.4.tar.gz"],
  }

  # gcc 12 / OpenSSL 3 raise deprecation warnings only; keep them non-fatal
  # provider shell: the posix provider cannot resolve a relative './configure'
  exec { 'build and install amap':
    provider  => shell,
    command   => './configure --prefix=/usr/local && make && make install',
    path      => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    cwd       => "${build_dir}/amap-5.4",
    creates   => '/usr/local/bin/amap',
    timeout   => 0,
    logoutput => true,
    require   => [Exec['extract amap'], Package['build-essential'], Package['libssl-dev'], Package['libpcre3-dev']],
  }

  file { '/usr/bin/amap':
    ensure  => link,
    target  => '/usr/local/bin/amap',
    require => Exec['build and install amap'],
  }
}
