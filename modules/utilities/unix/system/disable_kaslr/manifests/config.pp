# Disable KASLR by adding nokaslr to the kernel command line. A helper script
# appends the parameter (keeping any existing ones) and regenerates GRUB; the
# change takes effect on the next boot.
class disable_kaslr::config {
  file { '/usr/local/sbin/secgen-enable-nokaslr':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/disable_kaslr/enable_nokaslr.sh',
  }

  exec { 'disable_kaslr enable nokaslr':
    command => '/usr/local/sbin/secgen-enable-nokaslr',
    unless  => 'grep -qE "^GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\\bnokaslr\\b" /etc/default/grub',
    path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    require => File['/usr/local/sbin/secgen-enable-nokaslr'],
  }
}
