# Definition tomcat::config::server::valve
#
# Configure a Valve element in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the root of the Tomcat installation
# - $class_name is the className attribute. If not specified, defaults to $name.
# - $parent_host is the Host element this Valve should be nested beneath. If not
#   specified, the Valve will be nested beneath the Engine under
#   $parent_service.
# - $parent_context is the Context element this Valve should be nested beneath 
#   under the host element. If not specified, the Valve will be nested beneath
#   the parent host
# - $parent_service is the Service element this Valve should be nested beneath.
#   Defaults to 'Catalina'.
# - $valve_ensure specifies whether you are trying to add or remove the Vavle
#   element. Valid values are 'true', 'false', 'present', or 'absent'. Defaults
#   to 'present'.
# - An optional hash of $additional_attributes to add to the Valve. Should be of
#   the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Valve.
define tomcat::config::server::valve (
  $catalina_base         = undef,
  $class_name            = undef,
  $parent_host           = undef,
  $parent_service        = 'Catalina',
  $parent_context        = undef,
  $valve_ensure          = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $server_config         = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($valve_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)

  if $class_name {
    $_class_name = $class_name
  } else {
    $_class_name = $name
  }

  if $parent_host {
    if $parent_context {
      $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${parent_context}']/Valve[#attribute/className='${_class_name}']"
    } else {
      $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Valve[#attribute/className='${_class_name}']"
    }
  } else {
    $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Valve[#attribute/className='${_class_name}']"
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $valve_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $_class_name_change = "set ${base_path}/#attribute/className ${_class_name}"
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

    $changes = delete_undef_values(flatten([$_class_name_change, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "${_catalina_base}-${parent_service}-${parent_host}-valve-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
