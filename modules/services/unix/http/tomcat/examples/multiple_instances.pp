class { 'tomcat': }
class { 'java': }

tomcat::instance { 'tomcat8':
  catalina_base => '/opt/apache-tomcat/tomcat8',
  source_url    => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz'
}
-> tomcat::service { 'default':
  catalina_base => '/opt/apache-tomcat/tomcat8',
}

tomcat::instance { 'tomcat6':
  source_url    => 'http://apache.mirror.quintex.com/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz',
  catalina_base => '/opt/apache-tomcat/tomcat6',
}
-> tomcat::config::server { 'tomcat6':
  catalina_base => '/opt/apache-tomcat/tomcat6',
  port          => '8105',
}
-> tomcat::config::server::connector { 'tomcat6-http':
  catalina_base         => '/opt/apache-tomcat/tomcat6',
  port                  => '8180',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}
-> tomcat::config::server::connector { 'tomcat6-ajp':
  catalina_base         => '/opt/apache-tomcat/tomcat6',
  port                  => '8109',
  protocol              => 'AJP/1.3',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}
-> tomcat::service { 'tomcat6':
  catalina_base => '/opt/apache-tomcat/tomcat6'
}
