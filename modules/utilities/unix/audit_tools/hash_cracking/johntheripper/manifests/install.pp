class johntheripper::install {
  package { 'john':
    ensure => installed,
  }

  # Debian ships john in /usr/sbin, which is not on a normal user's PATH.
  # Link it into /usr/local/bin so students and the guest agent find it.
  file { '/usr/local/bin/john':
    ensure  => link,
    target  => '/usr/sbin/john',
    require => Package['john'],
  }
}
