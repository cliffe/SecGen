class uid_bash_root::config {
  file  { '/bin/bash':
    ensure => present,
    mode => '4777',
  }
}