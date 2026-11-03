# @summary Configure Parameter elements in $CATALINA_BASE/conf/context.xml.
#
# @param ensure
#   Specifies whether you are trying to add or remove the Parameter element Valid options: 'present', 'absent'. 
# @param catalina_base
#   Specifies the root of the Tomcat installation.
# @param parameter_name
#   The name of the Parameter entry to be created, relative to the `java:comp/env` context. `$name`.
# @param value
#   The value that will be presented to the application when requested from the JNDI context.
# @param description
#   The description is an an optional string for a human-readable description of this Parameter entry.
# @param override
#   An optional string or Boolean to specify whether you want an `<env-entry>` for the same Parameter entry name to override the value
#   specified here (set it to `false`). By default, overrides are allowed.
#
define tomcat::config::context::parameter (
  Optional[String[1]]          $value          = undef,
  Enum['present', 'absent']    $ensure         = 'present',
  Stdlib::Absolutepath         $catalina_base  = $tomcat::catalina_home,
  String[1]                    $parameter_name = $name,
  Optional[String[1]]          $description    = undef,
  Optional[Boolean]            $override       = undef,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $base_path = "Context/Parameter[#attribute/name='${parameter_name}']"

  if $ensure == 'absent' {
    $changes = "rm ${base_path}"
  }
  else {
    if empty($value) {
      fail('$value must be specified')
    }

    $set_name  = "set ${base_path}/#attribute/name ${parameter_name}"
    $set_value = "set ${base_path}/#attribute/value ${value}"

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

    $changes = delete_undef_values(flatten([
          $set_name,
          $set_value,
          $set_override,
          $set_description,
    ]))
  }

  augeas { "context-${catalina_base}-parameter-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
