# Definition: tomcat::config::server::service
#
# Configure a Service element nested in the Server element in
# $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the root of the Tomcat installation.
# - $class_name is the optional className attribute
# - $class_name_ensure specifies whether you are trying to set or remove the
#   className attribute. Valid values are 'true', 'false', 'present', or
#   'absent'. Defaults to 'present'.
# - $service_ensure specifies whether you are trying to add or remove the
#   service element. Valid values are 'true', 'false', 'present', or 'absent'.
#   Defaults to 'present'.
define tomcat::config::server::service (
  $catalina_base     = undef,
  $class_name        = undef,
  $class_name_ensure = 'present',
  $service_ensure    = 'present',
  $server_config     = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($service_ensure, '^(present|absent|true|false)$')
  validate_re($class_name_ensure, '^(present|absent|true|false)$')

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $service_ensure =~ /^(absent|false)$/ {
    $changes = "rm Server/Service[#attribute/name='${name}']"
  } else {
    if $class_name_ensure =~ /^(absent|false)$/ {
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
      lens    => 'Xml.lns',
      incl    => $_server_config,
      changes => $changes,
    }
  }
}
