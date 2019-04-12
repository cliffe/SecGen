# This code fragment downloads tomcat 7.0.53, creates an instance and adds a listener
#
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'mycat':
  catalina_base => '/opt/apache-tomcat/mycat',
  source_url    => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.53/bin/apache-tomcat-7.0.53.tar.gz',
}
-> tomcat::config::server::listener { 'mycat-jmx':
  catalina_base         => '/opt/apache-tomcat/mycat',
  listener_ensure       => present,
  class_name            => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
  additional_attributes => {
    'rmiRegistryPortPlatform' => '10001',
    'rmiServerPortPlatform'   => '10002',
  },
}
