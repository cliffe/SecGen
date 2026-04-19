# Class: lucee_rce::install
# Install process for lucee can be found at:
# https://docs.lucee.org/guides/installing-lucee/download-and-install.html
class lucee_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $modulename = 'lucee_rce'
  $releasename = 'lucee-express-5.3.7.43.zip'
  $splits = ["${releasename}.partaa",
  "${releasename}.partab"]

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  $splits.each |String $split| {
    file { "/tmp/${split}":
      ensure => file,
      source => "puppet:///modules/${modulename}/${split}",
    }
  }

  # Create user
  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }
  exec { 'download-jdk11':
    cwd     => '/tmp',
    command => 'wget -O jdk11.tar.gz https://download.java.net/openjdk/jdk11.0.0.2/ri/openjdk-11.0.0.2_linux-x64.tar.gz',
    creates => '/tmp/jdk11.tar.gz',
    timeout => 300,
  }
  -> exec { 'extract-jdk11':
    cwd     => '/tmp',
    command => 'tar -xzf jdk11.tar.gz',
    creates => '/tmp/jdk-11.0.0.2',
  }
  -> file { '/usr/lib/jvm':
    ensure => directory,
  }
  -> exec { 'install-jdk11':
    cwd     => '/tmp',
    command => 'mv jdk-11.0.0.2 /usr/lib/jvm/java-11-openjdk',
    creates => '/usr/lib/jvm/java-11-openjdk',
  }

  exec { 'rebuild-archive':
    cwd     => '/tmp/',
    command => "cat ${releasename}.parta* >/usr/local/src/${releasename}",
  }
  -> exec { 'unpack-lucee':
    cwd     => '/usr/local/src/',
    command => 'unzip -n lucee-express-5.3.7.43.zip',
  }
  -> file { '/usr/local/src/logs/':
    ensure => directory,
  }
  -> exec { 'giveperms-lucee':
    command => 'chmod -R 777 /usr/local/src/bin/',
  }
  -> exec { 'chmod-lucee':
    command => "chown -R ${user} /usr/local/src/",
  }
  -> exec { 'set-port':
    command => "sed -i 's/8888/${port}/' /usr/local/src/conf/server.xml"
  }
}
