# This code fragment downloads tomcat 7.0.53, creates an instance and adds a context to localhost
#
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'mycat':
  catalina_base => '/opt/apache-tomcat/mycat',
  source_url    => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.53/bin/apache-tomcat-7.0.53.tar.gz',
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
