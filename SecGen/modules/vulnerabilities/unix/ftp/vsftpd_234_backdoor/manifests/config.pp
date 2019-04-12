class vsftpd_234_backdoor::config {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $raw_org = $secgen_parameters['organisation']
  if $raw_org and $raw_org[0] and $raw_org[0] != '' {
    $organisation = parsejson($raw_org[0])
  } else {
    $organisation = ''
  }

  # Config files + manuals
  file { ['/usr/local/man/man5/vsftpd.conf.5']:
    require => File['/usr/local/src/vsftpd-2.3.4/Makefile'],
    ensure  => file,
    source  => '/usr/local/src/vsftpd-2.3.4/vsftpd.conf.5'
  }

  file { ['/usr/local/man/man8/vsftpd.8']:
    require => File['/usr/local/src/vsftpd-2.3.4/Makefile'],
    ensure  => file,
    source  => '/usr/local/src/vsftpd-2.3.4/vsftpd.8'
  }

  file { ['/etc/vsftpd.conf']:
    require => File['/usr/local/src/vsftpd-2.3.4/Makefile'],
    ensure  => file,
    content  => template('vsftpd_234_backdoor/vsftpd.conf.erb')
  }

  user { 'ftp':
    ensure     => present,
    uid        => '507',
    gid        => 'root',
    home       => '/var/ftp',
    require     => Exec["make-install-vsftpd"],
    managehome => true
  }

}
