# This code fragment will install the tomcat package from EPEL and start the service
#
class { 'tomcat': }
class { 'epel': }
-> tomcat::instance { 'default':
  install_from_source => false,
  package_name        => 'tomcat',
}
-> tomcat::service { 'default':
  use_jsvc     => false,
  use_init     => true,
  service_name => 'tomcat',
}
