# Install and configure php embedded SAPI
#
# === Parameters
#
# [*inifile*]
#   The path to the ini php5-embeded ini file
#
# [*settings*]
#   Hash with nested hash of key => value to set in inifile
#
# [*package*]
#   Specify which package to install
#
# [*ensure*]
#   Specify which version of the package to install
#
class php::embedded(
  $ensure   = $::php::ensure,
  $package  =
    "${::php::package_prefix}${::php::params::embedded_package_suffix}",
  $inifile  = $::php::params::embedded_inifile,
  $settings = {},
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::embedded is private')
  }

  validate_absolute_path($inifile)
  validate_hash($settings)

  $real_settings = deep_merge(
    $settings,
    hiera_hash('php::embedded::settings', {})
  )

  $real_package = $::osfamily ? {
    'Debian' => "lib${package}",
    default   => $package,
  }

  package { $real_package:
    ensure  => $ensure,
    require => Class['::php::packages'],
  }->
  ::php::config { 'embedded':
    file   => $inifile,
    config => $real_settings,
  }

}
