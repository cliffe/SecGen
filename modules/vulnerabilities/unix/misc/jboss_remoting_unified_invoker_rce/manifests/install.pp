class jboss_remoting_unified_invoker_rce::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
    environment => ['JAVA_HOME="/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/bin/java"']}

  ensure_packages(['apt-transport-https', 'ca-certificates', 'wget', 'dirmngr', 'gnupg', 'software-properties-common'])

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  # Create user
  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }

  file { '/usr/local/java':
    ensure => 'directory'
  }
  -> file { '/usr/local/java/jre-archive-files':
    ensure  => directory,
    source  => 'puppet:///modules/jboss_remoting_unified_invoker_rce/jre-archive-files',
    recurse => true,
  }
  -> exec { 'extract-java':
    command => 'cat jre-archive-files/jre* > jre-8u351-linux-x64.tar.gz; tar -xvzf jre-8u351-linux-x64.tar.gz',
    cwd     => '/usr/local/java',
    creates => '/usr/local/java/jre1.8.0_351'
  }
  -> tidy {'delete-jre-archive-parts':
    path    => '/usr/local/java/jre-archive-files',
    recurse => true,
  }
  tidy {'delete-jre-archive':
    path => '/usr/local/java/jre-8u351-linux-x64.tar.gz'
  }
  exec { 'change-java-install-dir-permissions':
    command => 'chmod -R 755 /usr/local/java',
  }
  -> exec { 'update-java-location':
    command => 'sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jre1.8.0_351/bin/java" 1',
  }
  -> file { '/opt/jboss-archive-files':
    ensure  => directory,
    source  => 'puppet:///modules/jboss_remoting_unified_invoker_rce/jboss-archive-files',
    recurse => true,
  }
  -> exec { 'unzip-jboss':
    command => 'cat jboss-archive-files/jboss* > jboss-as-distribution-6.1.0.Final.zip; unzip jboss-as-distribution-6.1.0.Final.zip',
    cwd     => '/opt',
    creates => '/opt/jboss-6.1.0.Final/bin'
  }
  -> exec { 'chown-jboss':
    command => "chown -R ${user} /opt/jboss-6.1.0.Final/",
  }
  -> tidy {'delete-jboss-archive-parts':
    path    => '/opt/jboss-archive-files',
    recurse => true,
  }
  tidy {'delete-jboss-archive':
    path => '/opt/jboss-as-distribution-6.1.0.Final.zip'
  }
  exec { 'set-listening-interface':
    command => 'echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> /opt/jboss-6.1.0.Final/bin/run.conf; mkdir /opt/made-interface',
    creates => '/opt/made-interface'
  }
  -> exec { 'change-permissions':
    command => 'chmod a+x /opt/jboss-6.1.0.Final',
  }
  -> file { '/etc/systemd/system/jboss.service':
    content => template('jboss_remoting_unified_invoker_rce/jboss.service.erb'),
  }
  -> service { 'jboss':
    ensure => running,
    enable => true,
  }
}
