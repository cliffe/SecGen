class writable_shadow::config {
  file { '/etc/shadow':
    ensure  => present,
    mode    => '0777',
  }
}
