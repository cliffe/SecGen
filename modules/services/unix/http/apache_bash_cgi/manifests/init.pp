class apache_bash_cgi::init {
  file { '/usr/lib/cgi-bin/':
    ensure => directory,
  }

  file { '/usr/lib/cgi-bin/test.cgi':
    ensure => file,
    source => 'puppet:///modules/apache_bash_cgi/test.cgi',
    mode => '755',
  }
}