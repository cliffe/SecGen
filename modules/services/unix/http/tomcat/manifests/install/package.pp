# @summary Private define to install Tomcat from a package.
#
# @api private
#
define tomcat::install::package (
  String[1] $package_name = $name,
  Optional[String[1]] $package_ensure = undef,
  Optional[Array[String[1]]] $package_options = undef,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { $package_name:
    ensure          => $package_ensure,
    install_options => $package_options,
  }
}
