$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

user { 'user':
  ensure => 'present',
  home => '/home/user',
  managehome => true,
  # password = user
  password => '$6$d4iZ7elwxATc$GhhVshEf7ho9jSBEDa1Zfh1A4hfAsB9KxyELSSfpqHxANLaWyaadWU1lBi5pFLzv68HwHOyYwQm097aqaHStP0',
}

file { '/home/user/testdir':
  ensure => 'directory',
}

file { ['/home/user/testfile', '/home/user/testdir/test']:
  ensure => 'file',
}


class { 'vsftpd':
  template         => 'vsftpd/vsftpd.conf.erb',
  anonymous_enable => false,
  ftpd_banner      => 'Hello, welcome to this vsftpd server!',
  local_enable => true,
  # userlist_enable => true,
}