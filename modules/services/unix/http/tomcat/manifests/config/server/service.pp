# @summary Configure a Service element nested in the Server element in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path.
# @param class_name
#   Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes). Valid options: a string containing a Java class name.
# @param class_name_ensure
#   Specifies whether the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes) should exist in the configuration file.
# @param service_ensure
#   Specifies whether the [Service element](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Introduction) should exist in the configuration file.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::service (
  Optional[Stdlib::Absolutepath] $catalina_base     = undef,
  Optional[String[1]]            $class_name        = undef,
  Enum['present','absent']       $class_name_ensure = 'present',
  Enum['present','absent']       $service_ensure    = 'present',
  Optional[String[1]]            $server_config     = undef,
  Boolean                        $show_diff         = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $service_ensure == 'absent' {
    $changes = "rm Server/Service[#attribute/name='${name}']"
  } else {
    if $class_name_ensure == 'absent' {
      $_class_name = "rm Server/Service[#attribute/name='${name}']/#attribute/className"
    } elsif $class_name {
      $_class_name = "set Server/Service[#attribute/name='${name}']/#attribute/className ${class_name}"
    } else {
      $_class_name = undef
    }
    $_service = "set Server/Service[#attribute/name='${name}']/#attribute/name ${name}"
    $changes = delete_undef_values([$_service, $_class_name])
  }

  if ! empty($changes) {
    augeas { "server-${_catalina_base}-service-${name}":
      lens      => 'Xml.lns',
      incl      => $_server_config,
      changes   => $changes,
      show_diff => $show_diff,
    }
  }
}
