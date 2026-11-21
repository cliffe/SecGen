class busybox_static::install {
  # The static build: one self-contained /bin/busybox that does not load the
  # victim's shared libraries or consult the dynamic loader, so it is immune to
  # a trojaned libc or an LD_PRELOAD / /etc/ld.so.preload userland rootkit.
  package { ['busybox-static']:
    ensure => 'installed',
  }
}
