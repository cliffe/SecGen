class suid_root_nano::config {
  file { '/bin/nano':
    mode => "4755",
    owner => "root",
    require => Package['nano'],
  }
  file { '/usr/bin/nano':
    mode => "4755",
    owner => "root",
    require => Package['nano'],
  }
}
