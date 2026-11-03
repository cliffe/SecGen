# This code fragment downloads tomcat 8.0.53, creates an instance and adds a role and user
#
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'mycat':
  catalina_base => '/opt/apache-tomcat/mycat',
  source_url    => 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.53/bin/apache-tomcat-8.0.53.tar.gz',
}
-> tomcat::config::server::tomcat_users {
  'mycat-role-tester':
    ensure        => present,
    catalina_base => '/opt/apache-tomcat/mycat',
    element       => 'role',
    element_name  => 'tester';
  'mycat-user-example':
    ensure        => present,
    catalina_base => '/opt/apache-tomcat/mycat',
    element       => 'user',
    element_name  => 'example',
    password      => 'very-secret-password',
    roles         => ['tester'];
}
