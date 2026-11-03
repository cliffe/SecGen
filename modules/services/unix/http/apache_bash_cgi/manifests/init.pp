class apache_bash_cgi::init {
  file { '/usr/lib/cgi-bin/':
    ensure => directory,
  }

  file { '/usr/lib/cgi-bin/test.cgi':
    ensure  => file,
    source  => 'puppet:///modules/apache_bash_cgi/test.cgi',
    mode    => '0755',
    require => File['/usr/lib/cgi-bin/'],
  }

  # ScriptAlias for /cgi-bin/. Dropped into the apache module's conf.d, which its
  # apache2.conf pulls in via IncludeOptional. The required apache module runs in
  # an earlier, separate puppet apply (SecGen applies one catalogue per module),
  # so its resources — Class['apache'], File['/etc/apache2/conf.d'] — are not in
  # this catalogue and must not be referenced. The <requires> tag orders the
  # applies, so the conf.d directory already exists on disk by the time we run.
  file { '/etc/apache2/conf.d/apache-bash-cgi.conf':
    ensure  => file,
    source  => 'puppet:///modules/apache_bash_cgi/cgi-bin.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/usr/lib/cgi-bin/test.cgi'],
    notify  => Exec['apache-bash-cgi-reload'],
  }

  # Restart apache so it reads the new ScriptAlias. refreshonly + the notify above
  # means this only fires when the conf file is (re)written.
  exec { 'apache-bash-cgi-reload':
    command     => 'systemctl restart apache2',
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    refreshonly => true,
  }
}
