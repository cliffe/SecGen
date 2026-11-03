# Installer process
class security_shepherd::install {
  include stdlib

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Temp fix. Seemed to not be able to generate this...
  file { '/etc/ssl/certs/java/':
    ensure => directory,
  }
  -> package { 'install-ca-certs':
    name => 'ca-certificates-java',
    ensure => installed,
  }

  ensure_packages(['tomcat9', 'mariadb-server', 'openjdk-11-jdk'], {ensure => installed})

  exec { 'remove-default-site':
    command => 'rm -rf /var/lib/tomcat9/webapps/*',
  }

  -> file { '/var/lib/tomcat9/webapps/ROOT.zip':
    ensure => file,
    source => 'puppet:///modules/security_shepherd/ROOT.zip',
  }

  -> file { ['/var/lib/tomcat9/webapps/ROOT', 
            '/var/lib/tomcat9/webapps/ROOT/WEB-INF', 
            '/var/lib/tomcat9/webapps/ROOT/WEB-INF/classes']:
    ensure => directory,
  }

  -> exec { 'extract ROOT':
    command => 'unzip -o ROOT.zip -d ROOT',
    cwd     => '/var/lib/tomcat9/webapps/',
    creates => '/var/lib/tomcat9/webapps/ROOT/admin/',
    path    => ['/usr/bin', '/bin'],
  }

  -> file { '/var/lib/tomcat9/conf/shepherdKeystore.p12':
    ensure => file,
    source => 'puppet:///modules/security_shepherd/shepherdKeystore.p12',
  }
  -> file { '/var/lib/tomcat9/conf/server.xml':
    ensure  => file,
    source  => 'puppet:///modules/security_shepherd/server.xml',
    replace => true,
  }
  -> file { '/var/lib/tomcat9/conf/web.xml':
    ensure  => file,
    source  => 'puppet:///modules/security_shepherd/web.xml',
    replace => true,
  }
  -> file { '/var/lib/tomcat9/conf/database.properties':
    ensure => file,
    source => 'puppet:///modules/security_shepherd/database.properties',
  }
  # A drop-in, not a replacement for /etc/mysql/my.cnf: that file belongs to the
  # mysql module (which this module requires), and replacing it dropped the
  # module's settings, skip-ssl included. Its my.cnf includes conf.d last.
  -> file { '/etc/mysql/conf.d/security_shepherd.cnf':
    ensure  => file,
    source  => 'puppet:///modules/security_shepherd/security_shepherd.cnf',
    require => Package['mariadb-server'],
  }
  # server.xml binds 80 and 443, and tomcat9 runs as the unprivileged 'tomcat'
  # user. Grant the bind capability explicitly so the connectors start whatever
  # the packaged unit file allows.
  -> file { '/etc/systemd/system/tomcat9.service.d':
    ensure => directory,
  }
  -> file { '/etc/systemd/system/tomcat9.service.d/bind-privileged-ports.conf':
    ensure  => file,
    content => "[Service]\nAmbientCapabilities=CAP_NET_BIND_SERVICE\n",
  }
  ~> exec { 'tomcat9-daemon-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
  # The package starts tomcat9 on install with the stock config; restart it so
  # the module's server.xml, web.xml and webapp are loaded now, not only after
  # the post-build reboot.
  ~> service { 'tomcat9':
    ensure     => running,
    name       => 'tomcat9',
    enable     => true,
    hasrestart => true,
  }

}
