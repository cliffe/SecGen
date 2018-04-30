# == Class: tomcat
#
# Class to manage installation and configuration of Tomcat.
#
# === Parameters
#
# [*catalina_home*]
#   The base directory for the Tomcat installation. Default: /opt/apache-tomcat
#
# [*user*]
#   The user to run Tomcat as. Default: tomcat
#
# [*group*]
#   The group to run Tomcat as. Default: tomcat
#
# [*manage_user*]
#   Boolean specifying whether or not to manage the user. Defaults to true.
#
# [*purge_connectors*]
#   Boolean specifying whether to purge all Connector elements from server.xml. Defaults to false.
#
# [*purge_realms*]
#   Boolean specifying whether to purge all Realm elements from server.xml. Defaults to false.
#
# [*manage_group*]
#   Boolean specifying whether or not to manage the group. Defaults to true.
#
# [*manage_properties*]
#   Boolean specifying whether or not to manage the catalina.properties file. Defaults to true.
class tomcat (
  $catalina_home       = $::tomcat::params::catalina_home,
  $user                = $::tomcat::params::user,
  $group               = $::tomcat::params::group,
  $install_from_source = true,
  $purge_connectors    = false,
  $purge_realms        = false,
  $manage_user         = true,
  $manage_group        = true,
  $manage_home         = true,
  $manage_base         = true,
  $manage_properties   = true,
) inherits ::tomcat::params {
  validate_bool($install_from_source)
  validate_bool($purge_connectors)
  validate_bool($purge_realms)
  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_bool($manage_home)
  validate_bool($manage_base)

  case $::osfamily {
    'windows','Solaris','Darwin': {
      fail("Unsupported osfamily: ${::osfamily}")
    }
    default: { }
  }
}
