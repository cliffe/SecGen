# Class: tomcat::params
#
# This class manages Tomcat parameters.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - The $user Tomcat runs as.
# - The $group Tomcat runs as.
class tomcat::params {
  $catalina_home = '/opt/apache-tomcat'
  $user          = 'tomcat'
  $group         = 'tomcat'
}
