tomcat::install { '/opt/tomcat':
  source_url => 'https://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.82/bin/apache-tomcat-7.0.82.tar.gz',
}
tomcat::instance { 'default':
  catalina_home => '/opt/tomcat',
}