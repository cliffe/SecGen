# @summary Specifies Valve elements in `${catalina_base}/conf/context.xml`
#
# @param ensure
#   Specifies whether you are trying to add or remove the Valve element.
# @param resource_name
#   Deprecated! Use `uniqueness_attributes`.
#   The name of the Resource to be created. Default: `$name` if `resource_type` is used.
#   Using this parameter will add an extra `name` attribute on the `valve` element.
#   As Tomcat allows multiple valves of the same className, this parameter has been used to create
#   unique representations of each element.
#   Adding a `name` attribute to a valve produces a warning in tomcat during load.
# @param resource_type
#   Deprecated! Use `class_name`
#   Java class name of the implementation to use.
# @param class_name
#   Java class name of the implementation to use. Default: `$name` if `resource_type` is not used.
# @param catalina_base
#   Specifies the root of the Tomcat installation. Default: `$tomcat::catalina_home`
# @param additional_attributes
#   Specifies any further attributes to add to the Valve. Valid options: a hash of '< attribute >' => '< value >' pairs. `{}`.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
# @param uniqueness_attributes
#   Specifies an array of attribute names that Puppet use to uniquely idetify valves. Valid options: an array of strings. `['className']`.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::valve (
  Enum['present','absent'] $ensure = 'present',
  Optional[String[1]] $resource_name  = undef,
  Optional[String[1]] $resource_type  = undef,
  Optional[String[1]] $class_name     = undef,
  Stdlib::Absolutepath $catalina_base = $tomcat::catalina_home,
  Hash $additional_attributes         = {},
  Array $attributes_to_remove         = [],
  Array $uniqueness_attributes        = [],
  Boolean $show_diff                  = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Valve configurations require Augeas >= 1.0.0')
  }

  if member($additional_attributes.keys, 'className') {
    fail('\'additional_attributes\' contains \'className\'. Please use parameter \'class_name\'')
  }

  if $resource_type !~ Undef {
    warning('Param \'resource_type\' is depredated. Please use \'class_name\'')
  }
  if $resource_name !~ Undef {
    warning('Param \'resource_name\' is depredated. Please use \'uniqueness_attributes\'')
  }

  if $class_name !~ Undef {
    $_class_name = $class_name
  } elsif $resource_type !~ Undef {
    $_class_name = $resource_type
  } else {
    $_class_name = $name
  }

  if $resource_name !~ Undef {
    $_name = $resource_name
  } elsif $resource_type !~ Undef {
    $_name = $name
  } else {
    $_name = undef
  }

  if $_name !~ Undef and !member($uniqueness_attributes, 'name') {
    if !member($uniqueness_attributes, 'className') {
      $_uniqueness_attributes = ['className'] + ['name'] + $uniqueness_attributes
    } else {
      $_uniqueness_attributes = ['name'] + $uniqueness_attributes
    }
  } else {
    if !member($uniqueness_attributes, 'className') {
      $_uniqueness_attributes = ['className'] + $uniqueness_attributes
    } else {
      $_uniqueness_attributes = $uniqueness_attributes
    }
  }

  if $_name !~ Undef {
    $attributes = { 'className' => $_class_name, 'name' => $_name } + $additional_attributes
  } else {
    $attributes = { 'className' => $_class_name } + $additional_attributes
  }

  $augeas_filter = $_uniqueness_attributes.map |$attr| {
    "[#attribute/${attr}='${attributes[$attr]}']"
  }

  $base_path = "Context/Valve${join($augeas_filter)}"

  if $ensure == 'absent' {
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

  augeas { "context-${catalina_base}-valve-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $changes,
    show_diff => $show_diff,
  }
}
