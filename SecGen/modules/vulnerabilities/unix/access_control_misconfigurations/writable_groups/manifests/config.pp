class writable_groups::config {
  file { '/etc/group':
    ensure  => present,
    mode    => '0777',
  }
}
