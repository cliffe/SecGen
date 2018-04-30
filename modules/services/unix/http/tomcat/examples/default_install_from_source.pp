# This code fragment downloads tomcat 8.0 then starts the service
#
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'test':
  source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz'
}
-> tomcat::service { 'default': }
