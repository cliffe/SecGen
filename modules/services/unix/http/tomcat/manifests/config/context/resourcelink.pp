# @summary Configure a ResourceLink element in the designated xml config.
#
# @param ensure
#   specifies whether you are trying to add or remove the ResourceLink element.
# @param catalina_base
#   Specifies the root of the Tomcat installation. `$tomcat::catalina_home`.
# @param resourcelink_name
#   The name of the ResourceLink to be created, relative to the `java:comp/env` context. `$name`.
# @param name
#   `$resourcelink_name`
# @param resourcelink_type
#   The fully qualified Java class name expected by the web application when it performs a lookup for this resource link.
# @param additional_attributes
#   Specifies any additional attributes to add to the Valve. Should be a hash of the format 'attribute' => 'value'. Optional
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::resourcelink (
  Enum['present','absent'] $ensure                = 'present',
  Stdlib::Absolutepath     $catalina_base         = $tomcat::catalina_home,
  String[1]                $resourcelink_name     = $name,
  Optional[String[1]]      $resourcelink_type     = undef,
  Hash                     $additional_attributes = {},
  Array                    $attributes_to_remove  = [],
  Boolean                  $show_diff             = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Context configurations require Augeas >= 1.0.0')
  }

  $base_path = "Context/ResourceLink[#attribute/name='${resourcelink_name}']"

  if $ensure == 'absent' {
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
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $augeaschanges,
    show_diff => $show_diff,
  }
}
