# This code fragment downloads tomcat 8.0.53, creates an instance and adds a listener
#
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'mycat':
  catalina_base => '/opt/apache-tomcat/mycat',
  source_url    => 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.53/bin/apache-tomcat-8.0.53.tar.gz',
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
