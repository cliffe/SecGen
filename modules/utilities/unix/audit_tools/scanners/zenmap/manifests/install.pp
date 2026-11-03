# Installs Zenmap. Debian 12 no longer packages it, so there it is built from the
# upstream Nmap source and registered with dpkg as a "zenmap" package.
class zenmap::install {
  if $::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '12') >= 0 {
    ensure_packages(['nmap', 'curl', 'ca-certificates', 'bzip2', 'gettext', 'python3', 'python3-pip',
      'python3-venv', 'python3-gi', 'python3-gi-cairo', 'gir1.2-gtk-3.0'])

    file { '/usr/local/sbin/build_zenmap_deb.sh':
      ensure => file,
      source => 'puppet:///modules/zenmap/build_zenmap_deb.sh',
      mode   => '0755',
    }

    exec { 'build and install zenmap':
      command  => '/usr/local/sbin/build_zenmap_deb.sh',
      unless   => 'dpkg -s zenmap 2>/dev/null | grep -q "^Status: install ok installed"',
      path     => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
      provider => shell,
      timeout  => 1200,
      require  => [File['/usr/local/sbin/build_zenmap_deb.sh'],
        Package['nmap', 'curl', 'ca-certificates', 'bzip2', 'gettext', 'python3-pip', 'python3-venv',
        'python3-gi', 'python3-gi-cairo', 'gir1.2-gtk-3.0']],
    }
  } else {
    package { 'zenmap':
      ensure => installed,
    }
  }
}
