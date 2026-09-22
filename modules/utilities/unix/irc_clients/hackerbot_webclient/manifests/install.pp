class hackerbot_webclient::install {
  ensure_packages(['python3'])

  file { '/opt/hackerbot_webclient':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
