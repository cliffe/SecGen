# Class: linuxki_rce::install
# Install process for linuxKI toolkit
#
class linuxki_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # Maybe automate linux-headers to use uname -r?
  ensure_packages(['make', 'elfutils', 'php', 'linux-headers-4.19.0-21-amd64'])

  file { '/tmp/linuxki_6.0-1_all.deb':
    ensure => file,
    source => 'puppet:///modules/linuxki_rce/linuxki_6.0-1_all.deb',
  }
  -> package { 'linuxki':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/linuxki_6.0-1_all.deb'
  }
}
