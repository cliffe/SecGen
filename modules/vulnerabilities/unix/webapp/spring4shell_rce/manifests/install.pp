# Installs Apache Tomcat 8.5.77 and deploys a vulnerable Spring MVC 5.3.17
# application (ROOT.war, served at /) on port 8080. Tomcat is pinned to 8.5.77:
# 8.5.78 added hardening that blocks the AccessLogValve JSP-write the exploit
# uses. Tomcat runs as an unprivileged 'tomcat' account, so the webshell lands a
# non-root shell. catalina.sh adds its own --add-opens flags on JDK 9+, so no
# extra Java options are needed for OpenJDK 17.
class spring4shell_rce::install {
  $catalina_home  = '/opt/tomcat'
  $tomcat_version = '8.5.77'
  $tarball        = "/var/tmp/apache-tomcat-${tomcat_version}.tar.gz"

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  group { 'tomcat':
    ensure => present,
    system => true,
  }
  user { 'tomcat':
    ensure  => present,
    system  => true,
    gid     => 'tomcat',
    home    => $catalina_home,
    shell   => '/usr/sbin/nologin',
    require => Group['tomcat'],
  }

  # Tomcat 8.5.77 is bundled rather than downloaded: archive.apache.org (the only
  # host that still serves this old release) is not reliably reachable from the
  # build network, and bundling makes the build reproducible and offline-safe.
  file { $tarball:
    ensure => file,
    source => "puppet:///modules/spring4shell_rce/apache-tomcat-${tomcat_version}.tar.gz",
  }

  # Unpack, then strip the shipped sample webapps so only the vulnerable app is
  # served (as ROOT -> /). Done in one exec so the removal runs only on extract.
  exec { 'extract tomcat':
    command => "mkdir -p ${catalina_home} && tar -xzf ${tarball} -C ${catalina_home} --strip-components=1 && rm -rf ${catalina_home}/webapps/*",
    creates => "${catalina_home}/bin/catalina.sh",
    require => File[$tarball],
  }

  file { "${catalina_home}/webapps/ROOT.war":
    ensure  => file,
    source  => 'puppet:///modules/spring4shell_rce/ROOT.war',
    require => Exec['extract tomcat'],
  }

  # Tomcat must own its tree so it can unpack ROOT.war and so the valve can write
  # the JSP into webapps/ROOT at exploit time.
  exec { 'chown tomcat tree':
    command     => "chown -R tomcat:tomcat ${catalina_home}",
    refreshonly => true,
    subscribe   => [Exec['extract tomcat'], File["${catalina_home}/webapps/ROOT.war"]],
    require     => User['tomcat'],
  }
}
