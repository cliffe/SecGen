# Installs bpftrace from the Debian archive and the Tracee release binaries under /opt/tracee,
# with /usr/local/bin/tracee pointing at the dynamically linked build, which loads the detection
# signatures in dist/signatures. Pinned to v0.23.2: later releases' dynamic build needs glibc 2.38,
# newer than Debian 12's, and the static build can't load the Go signature plugin.
class ebpf_tracing::install {
  Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

  $version = 'v0.23.2'
  $archive = "tracee-x86_64.${version}.tar.gz"
  $sha256  = '6a3f2cdc5023bc833d261cf4e3d84ff258b24a8b313f8f20438f0b04842060fa'

  ensure_packages(['bpftrace', 'wget', 'libelf1', 'zlib1g'])

  file { '/opt/tracee':
    ensure => directory,
    mode   => '0755',
  }

  # Downloaded under a temporary name, so a failed checksum leaves nothing for 'creates' to find.
  exec { 'download tracee':
    command  => "wget -q -O ${archive}.part https://github.com/aquasecurity/tracee/releases/download/${version}/${archive} && echo '${sha256}  ${archive}.part' | sha256sum -c && mv ${archive}.part ${archive}",
    cwd      => '/opt/tracee',
    provider => shell,
    creates  => "/opt/tracee/${archive}",
    timeout  => 1800,
    require  => [File['/opt/tracee'], Package['wget']],
  }

  # The archive unpacks to ./dist (tracee, tracee-static, tracee-ebpf, tracee-rules, signatures, man pages).
  exec { 'extract tracee':
    command => "tar -xzf ${archive} && rm -f ${archive}.part",
    cwd     => '/opt/tracee',
    creates => '/opt/tracee/dist/tracee',
    require => Exec['download tracee'],
  }

  file { '/usr/local/bin/tracee':
    ensure  => link,
    target  => '/opt/tracee/dist/tracee',
    require => Exec['extract tracee'],
  }
}
