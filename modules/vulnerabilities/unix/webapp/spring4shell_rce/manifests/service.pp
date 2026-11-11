# Runs Tomcat under systemd as the 'tomcat' user so it comes back after the
# reboot onto the isolated VLAN. catalina.sh finds /usr/bin/java via the JDK
# installed by the required java utility.
class spring4shell_rce::service {
  $catalina_home = '/opt/tomcat'

  file { '/etc/systemd/system/tomcat.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "[Unit]
Description=Apache Tomcat (Spring4Shell target)
After=network.target

[Service]
Type=simple
User=tomcat
Group=tomcat
Environment=CATALINA_HOME=${catalina_home}
Environment=CATALINA_BASE=${catalina_home}
ExecStart=${catalina_home}/bin/catalina.sh run
SuccessExitStatus=143
Restart=on-failure

[Install]
WantedBy=multi-user.target
",
    require => Class['spring4shell_rce::install'],
  }

  exec { 'tomcat systemd daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    subscribe   => File['/etc/systemd/system/tomcat.service'],
  }

  service { 'tomcat':
    ensure  => running,
    enable  => true,
    require => [Exec['tomcat systemd daemon-reload'], File['/etc/systemd/system/tomcat.service']],
  }
}
