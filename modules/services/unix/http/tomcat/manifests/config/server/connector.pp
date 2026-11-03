# @summary Configure Connector elements in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param connector_ensure
#   Specifies whether the [Connector XML element](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html) should exist in the configuration file.
# @param port
#    Sets a TCP port on which to create a server socket. Maps to the [port XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes). Valid options: a string.
# @param protocol
#   Specifies a protocol to use for handling incoming traffic. Maps to the [protocol XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes). Valid options: a string. `$name`.
# @param name
#   `$protocol`
# @param parent_service
#   Specifies which Service element the Connector should nest under. Valid options: a string containing the name attribute of the Service.
# @param additional_attributes
#   Specifies any further attributes to add to the Connector. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param purge_connectors
#   Specifies whether to purge any unmanaged Connector elements that match defined protocol but have a different port from the configuration file.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::connector (
  Optional[String[1]] $catalina_base         = undef,
  Enum['present','absent'] $connector_ensure = 'present',
  Optional[String[1]] $port                  = undef,
  String[1] $protocol                        = $name,
  String[1] $parent_service                  = 'Catalina',
  Hash $additional_attributes                = {},
  Array $attributes_to_remove                = [],
  Optional[Boolean] $purge_connectors        = undef,
  Optional[String[1]] $server_config         = undef,
  Boolean $show_diff                         = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))
  $_purge_connectors = pick($purge_connectors, $tomcat::purge_connectors)
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $_catalina_base !~ /^.*[^\/]$/ {
    fail('$catalina_base must not end in a /!')
  }

  $path = "Server/Service[#attribute/name='${parent_service}']"

  if $_purge_connectors {
    $__purge_connectors = "rm Server//Connector[#attribute/protocol='${protocol}'][#attribute/port!='${port}']"
  } else {
    $__purge_connectors = undef
  }

  if $_purge_connectors and ($connector_ensure == 'absent') {
    fail('$connector_ensure must be set to \'true\' or \'present\' to use $purge_connectors')
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $connector_ensure == 'absent' {
    if ! $port {
      $base_path = "${path}/Connector[#attribute/protocol='${protocol}']"
    } else {
      $base_path = "${path}/Connector[#attribute/port='${port}']"
    }
    $changes = "rm ${base_path}"
  } else {
    if ! $port {
      fail('$port must be specified unless $connector_ensure is set to \'absent\'')
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

    $changes = delete_undef_values(flatten([
          $__purge_connectors,
          $_port,
          $_protocol_change,
          $_additional_attributes,
          $_attributes_to_remove,
    ]))
  }

  augeas { "server-${_catalina_base}-${parent_service}-connector-${port}":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
