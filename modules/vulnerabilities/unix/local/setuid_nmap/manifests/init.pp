class setuid_nmap::init {
  file { '/usr/bin/nmap':
    mode => '4755',
  }
}