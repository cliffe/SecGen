# @summary Configure attributes for the Server element in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param class_name
#   Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) in the configuration file. Valid options: a string containing a Java class name.
# @param class_name_ensure
#   Specifies whether the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) should exist in the configuration file.
# @param address
#   Specifies a TCP/IP address on which to listen for the shutdown command. Maps to the [address XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes). Valid options: a string.
# @param address_ensure
#   Specifies whether the [address XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) should exist in the configuration file.
# @param port
#   Specifies a port on which to listen for the designated shutdown command. Maps to the [port XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes). Valid options: a string containing a port number.
# @param shutdown
#   Designates a command that shuts down Tomcat when the command is received through the specified address and port. Maps to the [shutdown XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes). Valid options: a string.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server (
  Optional[Stdlib::Absolutepath] $catalina_base     = undef,
  Optional[String[1]]            $class_name        = undef,
  Enum['present','absent']       $class_name_ensure = 'present',
  Optional[String[1]]            $address           = undef,
  Enum['present','absent']       $address_ensure    = 'present',
  Optional[String[1]]            $port              = undef,
  Optional[String[1]]            $shutdown          = undef,
  Optional[String[1]]            $server_config     = undef,
  Boolean                        $show_diff         = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $class_name_ensure == 'absent' {
    $_class_name = 'rm Server/#attribute/className'
  } elsif $class_name {
    $_class_name = "set Server/#attribute/className ${class_name}"
  } else {
    $_class_name = undef
  }

  if $address_ensure == 'absent' {
    $_address = 'rm Server/#attribute/address'
  } elsif $address {
    $_address = "set Server/#attribute/address ${address}"
  } else {
    $_address = undef
  }

  if $port {
    $_port = "set Server/#attribute/port ${port}"
  } else {
    $_port = undef
  }

  if $shutdown {
    $_shutdown = "set Server/#attribute/shutdown ${shutdown}"
  } else {
    $_shutdown = undef
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  $changes = delete_undef_values([$_class_name, $_address, $_port, $_shutdown])

  if ! empty($changes) {
    augeas { "server-${_catalina_base}":
      lens      => 'Xml.lns',
      incl      => $_server_config,
      changes   => $changes,
      show_diff => $show_diff,
    }
  }
}
