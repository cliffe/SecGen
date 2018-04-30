# Definition: tomcat::config::server::listener
#
# Configure Listener elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $listener_ensure specifies whether you are trying to add or remove the
#   Listener element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $class_name is the Java class name of the implementation to use.
#   Defaults to $name.
# - $parent_service is the Service element this Listener should be nested 
#   beneath. Only valid if $parent_host or $parent_engine is specified. Defaults
#   to 'Catalina' if $parent_host or $parent_engine was specified.
# - $parent_engine is the `name` attribute to the Engine element this Listener
#   should be nested beneath.
# - $parent_host is the `name` attribute to the Engine element this Listener
#   should be nested beneath.
# - An optional hash of $additional_attributes to add to the Listener. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Listener.
define tomcat::config::server::listener (
  $catalina_base         = $::tomcat::catalina_home,
  $listener_ensure       = 'present',
  $class_name            = undef,
  $parent_service        = undef,
  $parent_engine         = undef,
  $parent_host           = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $server_config         = undef,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($listener_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)

  if $parent_service and ! ($parent_host or $parent_engine) {
    warning('listener elements cannot be nested directly under service elements, ignoring $parent_service')
  }

  if ! $parent_service and ($parent_engine or $parent_host) {
    $_parent_service = 'Catalina'
  } else {
    $_parent_service = $parent_service
  }

  if $class_name {
    $_class_name = $class_name
  } else {
    $_class_name = $name
  }

  if $parent_engine and ! $parent_host {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${parent_engine}']/Listener[#attribute/className='${_class_name}']"
  } elsif $parent_engine and $parent_host {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${parent_engine}']/Host[#attribute/name='${parent_host}']/Listener[#attribute/className='${_class_name}']"
  } elsif $parent_host {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Listener[#attribute/className='${_class_name}']"
  } else {
    $path = "Server/Listener[#attribute/className='${_class_name}']"
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${catalina_base}/conf/server.xml"
  }

  if $listener_ensure =~ /^(absent|false)$/ {
    $augeaschanges = "rm ${path}"
  } else {
    $listener = "set ${path}/#attribute/className ${_class_name}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }

    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $augeaschanges = delete_undef_values(flatten([$listener, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "${catalina_base}-${_parent_service}-${parent_engine}-${parent_host}-listener-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $augeaschanges,
  }
}
