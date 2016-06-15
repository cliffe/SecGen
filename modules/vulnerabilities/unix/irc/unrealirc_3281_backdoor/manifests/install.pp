class unrealirc_3281_backdoor::install {
  
  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }

  $filename = "${unrealirc_3281_backdoor::filename}"
  $archive = "${filename}.tar.gz"
  $configure = "bash configure --with-showlistmodes --with-listen=5 --with-dpath=${unrealirc_3281_backdoor::install_path} --with-spath=${unrealirc_3281_backdoor::install_path}/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-permissions=0600 --with-fd-setsize=1024 --enable-dynamic-linking"

  # Create irc user and group
  group { $unrealirc_3281_backdoor::group:
    ensure  => present,
  }
  user { $unrealirc_3281_backdoor::group:
    ensure  => present,
    gid     => $unrealirc_3281_backdoor::group,
    require => Group[$unrealirc_3281_backdoor::group],
  }

  # Retrieve and unpack unrealirc
  file { "/tmp/${archive}":
    owner  => root,
    group  => root,
    mode   => '0775',
    ensure => file,
    source => "puppet:///modules/unrealirc_3281_backdoor/${archive}",
    notify => Exec['extract-unrealirc'],
  }

  exec { 'extract-unrealirc':
    command => "tar -xvzf /tmp/${archive}",
    cwd     => '/tmp',
    require => File["/tmp/${archive}"],
  }

  # Move extracted directory to install path
  exec { 'unrealirc-dir':
    command => "mv `ls -d /tmp/*/ | grep -i unreal | awk '{ print $1 }'` ${unrealirc_3281_backdoor::install_path}",
    creates => "${unrealirc_3281_backdoor::install_path}",
    require => Exec['extract-unrealirc'],
  }

  # Configure and make unrealircd, with or without ssl enabled
  if $unrealirc_3281_backdoor::use_ssl {
    package { 'libssl-dev': 
      ensure => present,
    }
    exec { 'make-unrealirc':
      command => "${configure} --enable-ssl && make",
      timeout => 0,
      cwd     => "${unrealirc_3281_backdoor::install_path}",
      creates => "${unrealirc_3281_backdoor::install_path}/unreal",
      require => [ Package['libssl-dev'], Exec['unrealirc-dir'] ],
    }
  } else {
    exec { 'make-unrealirc':
      command => "${configure} && make",
      timeout => 0,
      cwd     => "${unrealirc_3281_backdoor::install_path}",
      creates => "${unrealirc_3281_backdoor::install_path}/unreal",
      require => Exec['unrealirc-dir'],
    }
  }

  exec { 'chown-unrealirc-dir':
    command => "chown -R ${unrealirc_3281_backdoor::user}:${unrealirc_3281_backdoor::group} ${unrealirc_3281_backdoor::install_path}",
    require => [ Group[$unrealirc_3281_backdoor::group], User[$unrealirc_3281_backdoor::user], Exec['make-unrealirc'] ],
  }

  exec { 'remove-archive':
    command => "rm /tmp/${archive}"
  }

}
