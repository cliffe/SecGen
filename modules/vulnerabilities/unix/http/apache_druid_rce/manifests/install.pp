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
  exec { 'download-jdk8':
    cwd     => '/tmp',
    command => 'wget -O jdk8.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u432-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz',
    creates => '/tmp/jdk8.tar.gz',
    timeout => 300,
  }
  -> exec { 'extract-jdk8':
    cwd     => '/tmp',
    command => 'tar -xzf jdk8.tar.gz',
    creates => '/tmp/jdk8u432-b06',
  }
  -> exec { 'mkdir-jvm':
    cwd     => '/tmp',
    command => 'sudo mkdir /usr/lib/jvm;',
  }
  -> exec { 'install-jdk8':
    cwd     => '/tmp',
    command => 'mv jdk8u432-b06 /usr/lib/jvm/java-8-openjdk',
    creates => '/usr/lib/jvm/java-8-openjdk',
  }
  -> file { '/etc/profile.d/java8.sh':
    ensure  => file,
    content => "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk\nexport PATH=\$JAVA_HOME/bin:\$PATH\n",
    mode    => '0644',
  }

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
