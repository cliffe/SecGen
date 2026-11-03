# @summary Configure Manager elements in $CATALINA_BASE/conf/context.xml
#
# @param ensure
#   specifies whether you are trying to add or remove the Manager element.
# @param catalina_base
#   Specifies the root of the Tomcat installation.
# @param manager_classname
#   The name of the Manager to be created. `$name`.
# @param name
#   `$manager_classname`
# @param additional_attributes
#   Specifies any additional attributes to add to the Manager. Should be a hash of the format 'attribute' => 'value'. Optional
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::manager (
  Enum['present','absent'] $ensure                = 'present',
  Stdlib::Absolutepath     $catalina_base         = $tomcat::catalina_home,
  String[1]                $manager_classname     = $name,
  Hash                     $additional_attributes = {},
  Array                    $attributes_to_remove  = [],
  Boolean                  $show_diff             = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $manager_classname {
    $_manager_classname = $manager_classname
  } else {
    $_manager_classname = $name
  }

  $base_path = "Context/Manager[#attribute/className='${_manager_classname}']"

  if $ensure == 'absent' {
    $changes = "rm ${base_path}"
  } else {
    $set_name = "set ${base_path}/#attribute/className '${_manager_classname}'"

    if ! empty($additional_attributes) {
      $set_additional_attributes =
        suffix(prefix(join_keys_to_values($additional_attributes, " '"),
      "set ${base_path}/#attribute/"), "'")
    } else {
      $set_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $rm_attributes_to_remove =
        prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $rm_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([
          $set_name,
          $set_additional_attributes,
          $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-manager-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $changes,
    show_diff => $show_diff,
  }
}
