# Definition: tomcat::config::context::manager
#
# Configure Manager elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $ensure specifies whether you are trying to add or remove the
#   Manager element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $manager_name is the name of the Manager to be created, relative to
#   the java:comp/env context.
# - $type is the fully qualified Java class name expected by the web application
#   when it performs a lookup for this manager
# - An optional hash of $additional_attributes to add to the Manager. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Manager.
define tomcat::config::context::manager (
  $ensure                = 'present',
  $catalina_base         = $::tomcat::catalina_home,
  $manager_classname     = $name,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  if $manager_classname {
    $_manager_classname = $manager_classname
  } else {
    $_manager_classname = $name
  }

  $base_path = "Context/Manager[#attribute/className='${_manager_classname}']"

  if $ensure =~ /^(absent|false)$/ {
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
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
