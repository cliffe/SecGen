class maltrail_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $modulename = 'maltrail_rce'

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  # MalTrail tarball name (single file, no splitting needed)
  $tarball = 'maltrail-0.52.tar.gz'

  # Create dedicated user for MalTrail service
  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
    shell      => '/bin/bash',
  }

  group { $user:
    ensure => present,
  }

  ensure_packages(['python3', 'python3-pip', 'python3-dev', 'libpcap-dev', 'build-essential', 'python3-pcapy'])

  # Create user home directory with proper permissions
  file { $user_home:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0750',
    require => User[$user],
  }

  # OFFLINE: Copy MalTrail tarball
  file { "/tmp/${tarball}":
    ensure => file,
    source => "puppet:///modules/${modulename}/${tarball}",
  }

  # Extract MalTrail tarball (maltrail-0.52 directory format)
  exec { 'extract-maltrail':
    cwd     => '/tmp',
    command => "tar -xzf ${tarball}",
    creates => '/opt/maltrail',
    require => File["/tmp/${tarball}"],
  }

  # Move MalTrail to installation directory
  exec { 'install-maltrail':
    cwd     => '/tmp',
    command => 'mv maltrail-0.53 /opt/maltrail',
    creates => '/opt/maltrail',
    require => Exec['extract-maltrail'],
  }

  # Set ownership
  exec { 'chown-maltrail':
    command => "chown -R ${user}:${user} /opt/maltrail",
    require => Exec['install-maltrail'],
  }

  # Copy custom configuration file from template
  file { '/opt/maltrail/maltrail.conf':
    ensure  => file,
    content => template("${modulename}/maltrail.conf.erb"),
    owner   => $user,
    group   => $user,
    mode    => '0644',
    require => Exec['install-maltrail'],
  }
}
