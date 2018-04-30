# Definition: tomcat::config::context::environment
#
# Configure Environment elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $ensure specifies whether you are trying to add or remove the
#   Environment element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $catalina_base is the base directory for the Tomcat installation.
# - $environment_name is the name of the Environment to be created, relative to
#   the java:comp/env context.
# - $type is the fully qualified Java class name expected by the web application
#   for this environment entry.
# - $value that will be presented to the application when requested from
#   the JNDI context.
# - $description is an optional string for a human-readable description
#   of this environment entry.
# - Set $override to false if you do not want an <env-entry> for
#   the same environment entry name to override the value specified here.
# - An optional hash of $additional_attributes to add to the Environment. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Environment.
define tomcat::config::context::environment (
  $ensure                  = 'present',
  $catalina_base           = $::tomcat::catalina_home,
  $environment_name        = $name,
  $type                    = undef,
  $value                   = undef,
  $description             = undef,
  $override                = undef,
  $additional_attributes   = {},
  $attributes_to_remove    = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if is_bool($override) {
    $_override = bool2str($override)
  } else {
    $_override = $override
  }

  validate_re($ensure, '^(present|absent|true|false)$')
  validate_absolute_path($catalina_base)

  validate_string(
    $environment_name,
    $type,
    $value,
    $description,
  )

  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)

  $base_path = "Context/Environment[#attribute/name='${environment_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    if empty($type) {
      fail('$type must be specified')
    }

    if empty($value) {
      fail('$value must be specified')
    }

    $set_name  = "set ${base_path}/#attribute/name ${environment_name}"
    $set_type  = "set ${base_path}/#attribute/type ${type}"
    $set_value = "set ${base_path}/#attribute/value ${value}"

    if ! empty($_override) {
      validate_re($_override, '(true|false)', '$override must be true or false')
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
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
