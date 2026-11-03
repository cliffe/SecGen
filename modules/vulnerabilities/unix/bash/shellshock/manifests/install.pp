class shellshock::install{

  file { '/usr/local/src/bash-4.1.tar.gz':
    ensure => file,
    source => 'puppet:///modules/shellshock/bash-4.1.tar.gz',
  }

  exec { 'unpack-bash-tar':
    cwd         => '/usr/local/src',
    command     => '/bin/tar -xzf /usr/local/src/bash-4.1.tar.gz',
    creates     => '/usr/local/src/bash-4.1/',
    require     => File['/usr/local/src/bash-4.1.tar.gz'],
  }

  ensure_packages(['build-essential', 'gcc-multilib'])

  # Default --prefix is /usr/local, so this lands at /usr/local/bin/bash.
  exec { 'configure-make-make-install-bash':
    cwd     => '/usr/local/src/bash-4.1/',
    command => '/bin/bash /usr/local/src/bash-4.1/configure && /usr/bin/make && /usr/bin/make install',
    creates => '/usr/local/bin/bash',
    timeout => 900,
    require => [Exec['unpack-bash-tar'], Package['build-essential', 'gcc-multilib']],
  }

  # CVE-2014-6271 is only live on this box if /bin/bash itself (what CGI
  # scripts, forced SSH commands etc. actually invoke) is the vulnerable
  # build, not a side-by-side copy in /usr/local. Swap it in atomically (via a
  # temp file + rename) and keep the original for comparison/rollback.
  exec { 'replace-system-bash-with-vulnerable-build':
    command => '/bin/cp -f /bin/bash /usr/local/src/bash-original && /bin/cp /usr/local/bin/bash /bin/bash.new && /bin/mv -f /bin/bash.new /bin/bash',
    unless  => '/bin/bash --version | grep -q "version 4\.1"',
    require => Exec['configure-make-make-install-bash'],
  }
}