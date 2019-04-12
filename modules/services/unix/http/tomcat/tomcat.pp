tomcat::install { '/opt/tomcat':
  source_url => 'https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.91/bin/apache-tomcat-7.0.91.tar.gz',
}
tomcat::instance { 'default':
  catalina_home => '/opt/tomcat',
}
