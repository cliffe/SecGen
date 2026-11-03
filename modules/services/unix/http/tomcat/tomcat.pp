# Tomcat 9.0 supports the Java 17 that Debian 12 provides; 7.0.x does not.
tomcat::install { '/opt/tomcat':
  source_url => 'https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz',
}
# The module's own service (tomcat::service) starts catalina.sh once but does
# nothing at boot, so Tomcat was gone after a reboot. Manage it with a systemd
# unit instead.
tomcat::instance { 'default':
  catalina_home  => '/opt/tomcat',
  manage_service => false,
}

file { '/etc/systemd/system/tomcat.service':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => "[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=simple
User=tomcat
Group=tomcat
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
ExecStart=/opt/tomcat/bin/catalina.sh run
SuccessExitStatus=143
Restart=on-failure

[Install]
WantedBy=multi-user.target
",
  require => Tomcat::Install['/opt/tomcat'],
}

exec { 'tomcat systemd daemon-reload':
  command     => '/bin/systemctl daemon-reload',
  refreshonly => true,
  subscribe   => File['/etc/systemd/system/tomcat.service'],
}

service { 'tomcat':
  ensure  => running,
  enable  => true,
  require => [Exec['tomcat systemd daemon-reload'], Tomcat::Instance['default']],
}
