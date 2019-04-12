class readable_shadow::config {
  file { '/etc/shadow':
    ensure  => present,
    mode    => '0622',
  }
}
