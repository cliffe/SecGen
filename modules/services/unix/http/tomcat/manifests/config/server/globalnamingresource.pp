# @summary Configure GlobalNamingResources Resource elements in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat instance. Valid options: a string containing an absolute path.
# @param resource_name
#   Optionally override the globalnamingresource name that is normally taken from the Puppet resource's `$name`.
# @param type
#   Specifies the type of element to create Valid options: `Resource`, `Environment` or any other valid node.
# @param ensure
#   Determines whether the specified XML element should exist in the configuration file.
# @param additional_attributes
#   Specifies any further attributes to add to the Host. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::globalnamingresource (
  Stdlib::Absolutepath $catalina_base = $tomcat::catalina_home,
  Optional[String[1]] $resource_name  = undef,
  String[1] $type                     = 'Resource',
  Enum['present','absent'] $ensure    = 'present',
  Hash $additional_attributes         = {},
  Array $attributes_to_remove         = [],
  Optional[String[1]] $server_config  = undef,
  Boolean $show_diff                  = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $catalina_base !~ /^.*[^\/]$/ {
    fail('$catalina_base must not end in a /!')
  }

  if $resource_name {
    $_resource_name = $resource_name
  } else {
    $_resource_name = $name
  }

  $base_path = "Server/GlobalNamingResources/${type}[#attribute/name='${_resource_name}']"

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${catalina_base}/conf/server.xml"
  }

  if $ensure == 'absent' {
    $changes = "rm ${base_path}"
  } else {
    if ! empty($additional_attributes) {
      $set_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $set_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $rm_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $rm_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([
          $set_additional_attributes,
          $rm_attributes_to_remove,
    ]))

    # (MODULES-3353) This should use $set_name in $changes like
    # t:config::context::resource and others instead of an additional augeas
    # resource
    augeas { "server-${catalina_base}-globalresource-${name}-definition":
      lens      => 'Xml.lns',
      incl      => $_server_config,
      changes   => "set ${base_path}/#attribute/name '${_resource_name}'",
      before    => Augeas["server-${catalina_base}-globalresource-${name}"],
      show_diff => $show_diff,
    }
  }

  augeas { "server-${catalina_base}-globalresource-${name}":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
