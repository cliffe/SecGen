# @summary Configure a Valve element in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path. `$::tomcat::catalina_home`.
# @param class_name
#   Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Logging/Attributes). Valid options: a string containing a Java class name.
# @param parent_host
#   Specifies which virtual host the Valve should nest under. Valid options: a string containing the name of a Host element.
# @param parent_service
#   Specifies which Service element the Valve should nest under. Valid options: a string containing the name of a Service element.
# @param parent_context
#   Specifies which Context element the Valve should nest under. Valid options: a string containing the name of a Context element (matching the docbase attribute).
# @param valve_ensure
#   Specifies whether the Valve should exist in the configuration file. Maps to the  [Valve XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Introduction).
# @param additional_attributes
#   Specifies any further attributes to add to the Valve. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param uniqueness_attributes
#   Specifies an array of attribute names that Pupet use to uniquely idetify valves. Valid options: an array of strings. `['className']`.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::valve (
  Optional[Stdlib::Absolutepath] $catalina_base         = undef,
  Optional[String[1]]            $class_name            = undef,
  Optional[String[1]]            $parent_host           = undef,
  String                         $parent_service        = 'Catalina',
  Optional[String[1]]            $parent_context        = undef,
  Enum['present','absent']       $valve_ensure          = 'present',
  Hash                           $additional_attributes = {},
  Array                          $attributes_to_remove  = [],
  Array                          $uniqueness_attributes = [],
  Optional[String[1]]            $server_config         = undef,
  Boolean                        $show_diff             = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Valve configurations require Augeas >= 1.0.0')
  }

  if member($additional_attributes.keys, 'className') {
    fail('\'additional_attributes\' contains \'className\'. Please use parameter \'class_name\'')
  }

  if $class_name {
    $_class_name = $class_name
  } else {
    $_class_name = $name
  }

  if !member($uniqueness_attributes, 'className') {
    $_uniqueness_attributes = ['className'] + $uniqueness_attributes
  } else {
    $_uniqueness_attributes = $uniqueness_attributes
  }

  $attributes = { 'className' => $_class_name } + $additional_attributes

  $augeas_filter = $_uniqueness_attributes.map |$attr| {
    "[#attribute/${attr}='${attributes[$attr]}']"
  }

  # lint:ignore:140chars
  if $parent_host {
    if $parent_context {
      $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${parent_context}']/Valve${join($augeas_filter)}"
    } else {
      $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Valve${join($augeas_filter)}"
    }
  } else {
    $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Valve${join($augeas_filter)}"
  }
  # lint:endignore

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $valve_ensure == 'absent' {
    $changes = "rm ${base_path}"
  } else {
    $defnode_valve = "defnode valve ${base_path} ''"
    $set_attributes = join_keys_to_values($attributes, " '").map |$attr| {
      "set \$valve/#attribute/${attr}'"
    }
    if ! empty(any2array($attributes_to_remove)) {
      $rm_attributes = any2array($attributes_to_remove).map |$attr| {
        "rm \$valve/#attribute/${attr}"
      }
    } else {
      $rm_attributes = undef
    }

    $changes = delete_undef_values(flatten([
          $defnode_valve,
          $set_attributes,
          $rm_attributes,
    ]))
  }

  augeas { "${_catalina_base}-${parent_service}-${parent_host}-valve-${name}":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
