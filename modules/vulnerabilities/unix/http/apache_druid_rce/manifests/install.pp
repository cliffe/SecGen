# Class: apache_druid_rce::install
# Install process for apache druid RCE
# https://archive.apache.org/dist/druid/0.20.0/
class apache_druid_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $modulename = 'apache_druid_rce'

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  # Create user
  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }

  # This generates a repo file so we can get packages from debian stretch
  file { '/etc/apt/sources.list.d/stretch.list':
    ensure => file,
    source => "puppet:///modules/${modulename}/stretch.list"
  }
  -> exec { 'update-packages':
    command => 'apt update'
  }
  -> package { 'install-jdk8':
    ensure => 'installed',
    name   => 'openjdk-8-jdk',
  }
  # openjdk8 is required. Since we are buster, we need the repos within stretch for this
  #ensure_packages(['openjdk-8-jdk'], { ensure => 'installed'})

  $releasename = "${modulename}.tar.gz"
  $currentsource = ["${releasename}.partaa",
    "${releasename}.partab",
    "${releasename}.partac",
    "${releasename}.partad",
    "${releasename}.partae",
    "${releasename}.partaf",
    "${releasename}.partag"]

  $currentsource.each |String $fsource| {
    file { "/tmp/${fsource}":
      ensure => file,
      source => "puppet:///modules/${modulename}/${fsource}",
    }
  }

  exec { 'rebuild-archive':
    cwd     => '/tmp/',
    command => "cat ${releasename}.parta* > ${releasename}",
  }
  -> exec { 'unpack-druid':
    cwd     => '/tmp',
    command => "tar -xf ${releasename}",
    creates => '/tmp/apache-druid-0.20.0',
  }
  -> exec { 'move-druid':
    cwd     => '/tmp',
    command => 'mv apache-druid-0.20.0 /usr/local/apache-druid/',
    creates => '/usr/local/apache-druid'
  }
  -> exec { 'chmod-druid':
    command => 'chmod -R 777 /usr/local/apache-druid/bin/',
  }
  -> exec { 'chown-druid':
    command => "chown -R ${user}:${user} /usr/local/apache-druid/",
  }
  -> exec { 'change-port':
    command => "sed -i 's/8888/${port}/' /usr/local/apache-druid/conf/druid/single-server/nano-quickstart/router/runtime.properties",
  }
}
