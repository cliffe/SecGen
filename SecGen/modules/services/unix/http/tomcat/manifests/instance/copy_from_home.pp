# Definition: tomcat::instance::copy_from_home
#
# Private define to copy a conf file from catalina_home to catalina_base
#
define tomcat::instance::copy_from_home (
  $catalina_home,
  $user,
  $group,
) {
  tag(sha1($catalina_home))
  $filename = basename($name)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $name:
    ensure  => file,
    mode    => '0660',
    owner   => $user,
    group   => $group,
    source  => "${catalina_home}/conf/${filename}",
    replace => false,
  }
}
