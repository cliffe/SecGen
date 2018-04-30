# Definition: tomcat::config::server
#
# Configure attributes for the Server element in $CATALINA_BASE/conf/server.xml
#
# Parameters
# - $catalina_base is the base directory for the Tomcat installation.
# - $class_name is the optional className attribute.
# - $class_name_ensure specifies whether you are trying to set or remove the
#   className attribute. Valid values are 'true', 'false', 'present', or
#   'absent'. Defaults to 'present'.
# - $address is the optional address attribute.
# - $address_ensure specifies whether you are trying to set of remove the
#   address attribute. Valid values are 'true', 'false', 'present', or
#   'absent'. Defaults to 'present'.
# - The $port to wait for shutdown commands on.
# - The $shutdown command that must be sent to $port.
define tomcat::config::server (
  $catalina_base           = undef,
  $class_name              = undef,
  $class_name_ensure       = 'present',
  $address                 = undef,
  $address_ensure          = 'present',
  $port                    = undef,
  $shutdown                = undef,
  $server_config           = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($class_name_ensure, '^(present|absent|true|false)$')
  validate_re($address_ensure, '^(present|absent|true|false)$')

  if $class_name_ensure =~ /^(absent|false)$/ {
    $_class_name = 'rm Server/#attribute/className'
  } elsif $class_name {
    $_class_name = "set Server/#attribute/className ${class_name}"
  } else {
    $_class_name = undef
  }

  if $address_ensure =~ /^(absent|false)$/ {
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
      lens    => 'Xml.lns',
      incl    => $_server_config,
      changes => $changes,
    }
  }
}
