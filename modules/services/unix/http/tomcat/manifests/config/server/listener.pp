# @summary Configure Listener elements in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path.
# @param listener_ensure
#   Specifies whether the [Listener XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html) should exist in the configuration file.
# @param class_name
#   Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#Common_Attributes) of a Listener Element. Valid options: a string containing a Java class name. `$name`.
# @param parent_service
#   Specifies which Service element the Listener should nest under. Only valid if `parent_engine` or `parent_host` is specified. Valid options: a string containing the name attribute of the Service.
# @param parent_engine
#   Specifies which Engine element this Listener should nest under. Valid options: a string containing the name attribute of the Engine.
# @param parent_host
#   Specifies which Host element this Listener should nest under. Valid options: a string containing the name attribute of the Host.
# @param additional_attributes
#   Specifies any further attributes to add to the Listener. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::listener (
  Stdlib::Absolutepath $catalina_base       = $tomcat::catalina_home,
  Enum['present','absent'] $listener_ensure = 'present',
  Optional[String[1]] $class_name           = undef,
  Optional[String[1]] $parent_service       = undef,
  Optional[String[1]] $parent_engine        = undef,
  Optional[String[1]] $parent_host          = undef,
  Hash $additional_attributes               = {},
  Array $attributes_to_remove               = [],
  Optional[String[1]] $server_config        = undef,
  Boolean $show_diff                        = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

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

  # lint:ignore:140chars
  if $parent_engine and ! $parent_host {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${parent_engine}']/Listener[#attribute/className='${_class_name}']"
  } elsif $parent_engine and $parent_host {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${parent_engine}']/Host[#attribute/name='${parent_host}']/Listener[#attribute/className='${_class_name}']"
  } elsif $parent_host {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Listener[#attribute/className='${_class_name}']"
  } else {
    $path = "Server/Listener[#attribute/className='${_class_name}']"
  }
  # lint:endignore

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${catalina_base}/conf/server.xml"
  }

  if $listener_ensure == 'absent' {
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
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $augeaschanges,
    show_diff => $show_diff,
  }
}
