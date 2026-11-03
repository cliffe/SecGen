# @summary Configure Resources elements in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param resources_ensure
#   Specifies whether the resources ([The Resources Component](https://tomcat.apache.org/tomcat-8.0-doc/config/resources.html#Introduction)) should exist in the configuration file.
# @param parent_service
#   Specifies which Service element the Host should nest under. Valid options: a string containing the name attribute of the Service.
# @param parent_engine
#   Specifies which Engine element the Context should nest under. Only valid if `parent_host` is specified. Valid options: a string containing the name attribute of the Engine.
# @param parent_host
#   Specifies which Host element the Context should nest under. Valid options: a string containing the name attribute of the Host.
# @param parent_context
#   Specifies which Context element the Context should nest under. Valid options: a string containing the name attribute of the Context.
# @param additional_attributes
#   Specifies any further attributes to add to the Host. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::resources (
  Optional[Stdlib::Absolutepath] $catalina_base         = undef,
  Enum['present','absent']       $resources_ensure      = 'present',
  Optional[String[1]]            $parent_service        = undef,
  Optional[String[1]]            $parent_engine         = undef,
  Optional[String[1]]            $parent_host           = undef,
  Optional[String[1]]            $parent_context        = undef,
  Hash                           $additional_attributes = {},
  Array[String[1]]               $attributes_to_remove  = [],
  Optional[String[1]]            $server_config         = undef,
  Boolean                        $show_diff             = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $parent_service {
    $_parent_service = $parent_service
  } else {
    $_parent_service = 'Catalina'
  }

  if $parent_engine and ! $parent_host {
    warning('context elements cannot be nested directly under engine elements, ignoring $parent_engine')
  }

  if $parent_engine and $parent_host {
    $_parent_engine = $parent_engine
  } else {
    $_parent_engine = undef
  }

  if $parent_context {
    $_parent_context = $parent_context
  } else {
    $_parent_context = $name
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  # lint:ignore:140chars
  if $parent_host and ! $_parent_engine {
    $parent = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_parent_context}']"
  } elsif $parent_host and $_parent_engine {
    $parent = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${_parent_engine}']/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_parent_context}']"
  } else {
    $parent = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host/Context[#attribute/docBase='${_parent_context}']"
  }
  $path = "${parent}/Resources"
  # lint:endignore

  if $resources_ensure == 'absent' {
    $augeaschanges = "rm ${path}"
  } else {
    $_container = [
      "set ${parent} ''",
      "set ${path} #empty",
    ]

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

    $augeaschanges = delete_undef_values(flatten([$_container, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "${_catalina_base}-${_parent_service}-${_parent_engine}-${parent_host}-context-${_parent_context}-resources":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $augeaschanges,
    show_diff => $show_diff,
  }
}
