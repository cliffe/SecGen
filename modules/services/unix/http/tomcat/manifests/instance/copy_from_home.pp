# @summary Private define to copy a conf file from catalina_home to catalina_base
#
# @api private
#
define tomcat::instance::copy_from_home (
  String[1] $catalina_home,
  String[1] $user,
  String[1] $group,
  String[1] $mode,
) {
  tag(sha1($catalina_home))
  $filename = basename($name)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $name:
    ensure  => file,
    mode    => $mode,
    owner   => $user,
    group   => $group,
    source  => "${catalina_home}/conf/${filename}",
    replace => false,
  }
}
