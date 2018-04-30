# Definition: tomcat::install::package
#
# Private define to install Tomcat from a package.
#
# Parameters:
# - $package_ensure is the ensure passed to the package resource.
# - The $package_name you want to install.
# - $package_options to pass extra options to the package resource.
define tomcat::install::package (
  $package_ensure,
  $package_options,
  $package_name = $name,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { $package_name:
    ensure          => $package_ensure,
    install_options => $package_options,
  }
}
