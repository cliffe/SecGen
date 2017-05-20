# Install common PHP packages
#
# === Parameters
#
# [*ensure*]
#   Specify which version of PHP packages to install
#
# [*names*]
#   List of the names of the package to install
#
# [*names_to_prefix*]
#   List of packages names that should be prefixed with the common
#   package prefix `$php::package_prefix`
#
class php::packages (
  $ensure          = $::php::ensure,
  $names_to_prefix = prefix(
    $::php::params::common_package_suffixes, $::php::package_prefix # lint:ignore:parameter_documentation
  ),
  $names           = $::php::params::common_package_names,
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::packages is private')
  }

  validate_string($ensure)
  validate_array($names)
  validate_array($names_to_prefix)

  $real_names = union($names, $names_to_prefix)
  if $::operatingsystem == 'Ubuntu' {
    package { $real_names:
      ensure  => $ensure,
      require => Class['::apt::update'],
    }
  } else {
    package { $real_names:
      ensure => $ensure,
    }
  }
}
