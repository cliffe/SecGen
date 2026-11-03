# Class: linuxki_rce::install
# Install process for linuxKI toolkit
#
class linuxki_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # make/elfutils support the package's own postinst (it tries to build a
  # kernel module for trace capture, falling back to a warning if it can't -
  # see linuxki_install/module_prep in the .deb). That kernel module is not
  # needed for the web RCE this module exploits, so we don't chase a matching
  # linux-headers package for whatever kernel the base happens to be running;
  # a hardcoded 'linux-headers-4.19.0-21-amd64' (Stretch-era) doesn't exist on
  # Bookworm and would fail the package install outright for no benefit.
  # PHP itself is NOT installed here: it comes from the required php7 utility
  # module (modules/utilities/unix/languages/php7), which installs PHP 7.4 and
  # makes it the default `php` CLI -- needed because kivis.php's bare (unquoted)
  # case labels in its switch statement fatal under Debian 12's stock PHP 8.2
  # (undefined constant), breaking the vulnerable endpoint entirely.
  ensure_packages(['make', 'elfutils'])

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
