class binary_script_container::install {
  # Create install directory
  file { '/root/suid/':
    ensure => directory,
  }

  # Move wrapper.c onto box
  file { "/root/suid/suid.c":
    ensure => file,
    source => 'puppet:///modules/binary_script_container/wrapper.c',
  }

  # Make and install
  exec { "wrapper make install":
    command => 'make suid; install -m a+rx,u+ws -s ./suid /usr/local/bin/suid',
    cwd => '/root/suid/',
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
}