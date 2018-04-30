# This code fragment downloads Tomcat 8.0.15, configures an instance, and adds a JNDIRealm nested under a LockOutRealm.
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'tomcat8':
  source_url   => 'http://mirror.reverse.net/pub/apache/tomcat/tomcat-8/v8.0.15/bin/apache-tomcat-8.0.15.tar.gz',
  purge_realms => true,
}

-> tomcat::config::server::realm { 'org.apache.catalina.realm.LockOutRealm':
  realm_ensure => 'present',
}

-> tomcat::config::server::realm { 'org.apache.catalina.realm.JNDIRealm':
  realm_ensure          => 'present',
  parent_realm          => 'org.apache.catalina.realm.LockOutRealm',
  additional_attributes => {
    'connectionURL' => 'ldap://localhost'
  },
}
