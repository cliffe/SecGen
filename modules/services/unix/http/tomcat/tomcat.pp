# Tomcat 9.0 supports the Java 17 that Debian 12 provides; 7.0.x does not.
# Download from the live CDN mirror (dlcdn), not archive.apache.org: from the
# build network archive.apache.org fails the TLS handshake (curl exit 35) and
# throttles large transfers, which broke provisioning here. The CDN serves the
# tarball in well under a second. The trade-off is that dlcdn keeps only the
# latest few 9.0.x releases, so this URL needs bumping when 9.0.123 ages out of
# the mirror; archive.apache.org keeps every release but is unreliable from here.
tomcat::install { '/opt/tomcat':
  source_url => 'https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.123/bin/apache-tomcat-9.0.123.tar.gz',
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
