class writeable_shadow::config {

  file { '/etc/shadow':
    ensure  => present,
    mode    => '0777',
  }


}
