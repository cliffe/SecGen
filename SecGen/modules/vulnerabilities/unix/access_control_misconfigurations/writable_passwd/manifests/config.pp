class writable_passwd::config {
  file { '/etc/passwd':
    ensure  => present,
    mode    => '0777',
  }
}
