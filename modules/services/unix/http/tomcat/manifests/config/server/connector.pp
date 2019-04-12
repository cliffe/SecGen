# Definition: tomcat::config::server::connector
#
# Configure Connector elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $connector_ensure specifies whether you are trying to add or remove the
#   Connector element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - The $port attribute. This attribute is required unless $connector_ensure
#   is set to false.
# - The $protocol attribute. Defaults to $name when not specified.
# - $parent_service is the Service element this Connector should be nested
#   beneath. Defaults to 'Catalina'.
# - An optional hash of $additional_attributes to add to the Connector. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::server::connector (
  $catalina_base         = undef,
  $connector_ensure      = 'present',
  $port                  = undef,
  $protocol              = $name,
  $parent_service        = 'Catalina',
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $purge_connectors      = undef,
  $server_config         = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))
  $_purge_connectors = pick($purge_connectors, $::tomcat::purge_connectors)
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($connector_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_bool($_purge_connectors)
  validate_re($_catalina_base, '^.*[^/]$', '$catalina_base must not end in a /!')

  $path = "Server/Service[#attribute/name='${parent_service}']"

  if $_purge_connectors {
    $__purge_connectors = "rm Server//Connector[#attribute/protocol='${protocol}'][#attribute/port!='${port}']"
  } else {
    $__purge_connectors = undef
  }

  if $_purge_connectors and ($connector_ensure =~ /^(absent|false)$/) {
    fail('$connector_ensure must be set to \'true\' or \'present\' to use $purge_connectors')
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $connector_ensure =~ /^(absent|false)$/ {
    if ! $port {
      $base_path = "${path}/Connector[#attribute/protocol='${protocol}']"
    } else {
      $base_path = "${path}/Connector[#attribute/port='${port}']"
    }
    $changes = "rm ${base_path}"
  } else {
    if ! $port {
      fail('$port must be specified unless $connector_ensure is set to \'absent\' or \'false\'')
    }

    $base_path = "${path}/Connector[#attribute/port='${port}']"
    $_port = "set ${base_path}/#attribute/port ${port}"
    $_protocol_change = "set ${base_path}/#attribute/protocol ${protocol}"
    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([ $__purge_connectors, $_port, $_protocol_change, $_additional_attributes, $_attributes_to_remove ]))
  }

  augeas { "server-${_catalina_base}-${parent_service}-connector-${port}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
