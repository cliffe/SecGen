# Installs LiME (Linux Memory Extractor) and builds its kernel module.
# Headers are needed for every kernel the VM may boot: the running one, and
# the newest one installed (the update module can install a newer kernel that
# only becomes the running kernel after the post-provision reboot).
class lime::install{
  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  # linux-headers-amd64 tracks the newest kernel in the repository
  ensure_packages(['git','build-essential','linux-headers-amd64'])

  # Headers for the running kernel; the exact version may have left the
  # repository, in which case the metapackage above is the fallback.
  exec { 'install running kernel headers for LiME':
    command  => "apt-get install -y linux-headers-${facts['kernelrelease']} || true",
    provider => 'shell',
    unless   => "dpkg -s linux-headers-${facts['kernelrelease']} 2>/dev/null | grep -q 'Status: install ok installed'",
    timeout  => 600,
    require  => Package['linux-headers-amd64'],
  }

  exec {'clone LiME repo':
    command => 'git clone https://github.com/504ensicsLabs/LiME.git',
    cwd     => '/root/',
    creates => '/root/LiME/src',
    timeout => 600,
    require => Package['git'],
  }

  # Build against every kernel that has headers installed. Each build is
  # kept as lime-<version>.ko (make clean would remove earlier output).
  exec {'make LiME kernel object':
    command  => 'mkdir -p /root/lime-out; for d in /lib/modules/*/build; do [ -e "$d/Makefile" ] || continue; k=$(basename $(dirname $d)); make clean >/dev/null 2>&1; make KVER=$k && mv lime-$k.ko /root/lime-out/; done; mv /root/lime-out/*.ko /root/LiME/src/ && rmdir /root/lime-out',
    provider => 'shell',
    cwd      => '/root/LiME/src/',
    unless   => 'ls /root/LiME/src/lime-*.ko',
    timeout  => 1200,
    require  => [Exec['clone LiME repo'], Exec['install running kernel headers for LiME'], Package['build-essential']],
  }
}
