# This code fragment downloads tomcat 8.0.53, creates an instance and adds a context to localhost
#
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'mycat':
  catalina_base => '/opt/apache-tomcat/mycat',
  source_url    => 'https://downloads.apache.org/tomcat/tomcat-8/v8.0.53/bin/apache-tomcat-8.0.53-deployer.tar.gz',
}
-> tomcat::config::server::context { 'mycat-test':
  catalina_base         => '/opt/apache-tomcat/mycat',
  context_ensure        => present,
  doc_base              => 'test.war',
  parent_service        => 'Catalina',
  parent_engine         => 'Catalina',
  parent_host           => 'localhost',
  additional_attributes => {
    'path' => '/test',
  },
}
