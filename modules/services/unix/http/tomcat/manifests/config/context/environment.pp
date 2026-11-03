# @summary Configure Environment elements in $CATALINA_BASE/conf/context.xml
#
# @param ensure
#   Specifies whether you are trying to add or remove the Environment element Valid options: 'present', 'absent'. 
# @param catalina_base
#   Specifies the root of the Tomcat installation. 
# @param environment_name
#   The name of the Environment Entry to be created, relative to the `java:comp/env` context. `$name`.
# @param name
#   `$environment_name`
# @param type
#   The fully qualified Java class name expected by the web application for this environment entry. Required to create the environment entry.
# @param value
#   The value that will be presented to the application when requested from the JNDI context. Required to create the environment entry.
# @param description
#   The description is an an optional string for a human-readable description of this environment entry.
# @param override
#   An optional string or Boolean to specify if you do not want an `<env-entry>` for the same environment entry name to override the value specified here (set it to `false`). By default, overrides are allowed.
# @param additional_attributes
#   Specifies any additional attributes to add to the Environment. Should be a hash of the format 'attribute' => 'value'.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::environment (
  Enum['present','absent'] $ensure    = 'present',
  Stdlib::Absolutepath $catalina_base = $tomcat::catalina_home,
  String[1] $environment_name         = $name,
  Optional[String[1]] $type           = undef,
  Optional[String[1]] $value          = undef,
  Optional[String[1]] $description    = undef,
  Optional[Boolean] $override         = undef,
  Hash $additional_attributes         = {},
  Array $attributes_to_remove         = [],
  Boolean $show_diff                  = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $base_path = "Context/Environment[#attribute/name='${environment_name}']"

  if $ensure == 'absent' {
    $changes = "rm ${base_path}"
  } else {
    if empty($type) {
      fail('$type must be specified')
    }

    if empty($value) {
      fail('$value must be specified')
    }

    $set_name  = "set ${base_path}/#attribute/name '${environment_name}'"
    $set_type  = "set ${base_path}/#attribute/type '${type}'"
    $set_value = "set ${base_path}/#attribute/value '${value}'"

    if $override != undef {
      $_override = bool2str($override)
      $set_override = "set ${base_path}/#attribute/override ${_override}"
    } else {
      $set_override = "rm ${base_path}/#attribute/override"
    }

    if ! empty($description) {
      $set_description = "set ${base_path}/#attribute/description \'${description}\'"
    } else {
      $set_description = "rm ${base_path}/#attribute/description"
    }

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
          $set_name,
          $set_type,
          $set_value,
          $set_override,
          $set_description,
          $set_additional_attributes,
          $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-environment-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $changes,
    show_diff => $show_diff,
  }
}
