class writable_shadow_config::config {

  file { '/etc/shadow':
    ensure  => present,
    mode    => '0777',
  }


}
