# Definition: tomcat::config::server::resourcelink
#
# Configure a ResourceLink element in the designated xml config.
#
# Parameters:
# - $ensure specifies whether you are trying to add or remove the
#   ResourceLink element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $catalina_base is the base directory for the Tomcat instance.
# - $resourcelink_name is the name of the resource link to be created, relative
#   to the java:comp/env context. Defaults to $name
# - $resourcelink_type is the fully qualified Java class name expected by the web
#   application when it performs a lookup for this resource link. Required
define tomcat::config::context::resourcelink (
  $ensure                = 'present',
  $catalina_base         = $::tomcat::catalina_home,
  $resourcelink_name     = $name,
  $resourcelink_type     = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Context configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  $base_path = "Context/ResourceLink[#attribute/name='${resourcelink_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $augeaschanges = "rm ${base_path}"
  } else {
    $set_name = "set ${base_path}/#attribute/name ${resourcelink_name}"
    if $resourcelink_type {
      $set_type = "set ${base_path}/#attribute/type ${resourcelink_type}"
    } else {
      $set_type = undef
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

    $augeaschanges = delete_undef_values(flatten([
      $set_name,
      $set_type,
      $set_additional_attributes,
      $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-resourcelink-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $augeaschanges,
  }
}
