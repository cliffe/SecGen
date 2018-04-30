# Definition: tomcat::config::server::globalnamingresource
#
# Configure GlobalNamingResources Resource elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $resource_ensure specifies whether you are trying to add or remove the
#   Resource element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - An optional $resource_name that replaces the $name from the resource.
# - An optional string containing the $type of the element. Used verbatim
#   to create a <GlobalNamingResources><${type} /></GlobalNamingResources>
#   node. Should be used for "Environment" entries, for example.
# - An optional hash of $additional_attributes to add to the Resource. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Resource.
define tomcat::config::server::globalnamingresource (
  $catalina_base         = $::tomcat::catalina_home,
  $resource_name         = undef,
  $type                  = 'Resource',
  $ensure                = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $server_config         = undef,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_re($catalina_base, '^.*[^/]$', '$catalina_base must not end in a /!')

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

  if $ensure =~ /^(absent|false)$/ {
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
  }

  # (MODULES-3353) This should use $set_name in $changes like
  # t:config::context::resource and others instead of an additional augeas
  # resource
  augeas { "server-${catalina_base}-globalresource-${name}-definition":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => "set ${base_path}/#attribute/name '${_resource_name}'",
    before  => Augeas["server-${catalina_base}-globalresource-${name}"],
  }

  augeas { "server-${catalina_base}-globalresource-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
