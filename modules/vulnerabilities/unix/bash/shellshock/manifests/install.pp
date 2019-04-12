class shellshock::install{

  file { '/usr/local/src/bash-4.1.tar.gz':
    ensure => file,
    source => 'puppet:///modules/shellshock/bash-4.1.tar.gz',
  }

  exec { 'unpack-bash-tar':
    cwd         => '/usr/local/src',
    command     => '/bin/tar -xzf /usr/local/src/bash-4.1.tar.gz',
    creates     => '/usr/local/src/bash-4.1/',
  }

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')

  exec { 'configure-make-make-install-bash':
    cwd     => '/usr/local/src/bash-4.1/',
    command => '/bin/bash /usr/local/src/bash-4.1/configure; /usr/bin/make; /usr/bin/make install;',
    require => [Exec['unpack-bash-tar'],Package['build-essential', 'gcc-multilib']],
  }
}