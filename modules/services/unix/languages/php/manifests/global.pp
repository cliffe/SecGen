# Install and configure mod_php for fpm
#
# === Parameters
#
# [*inifile*]
#   Absolute path to the global php.ini file. Defaults
#   to the OS specific default location as defined in params.
# [*settings*]
#   Hash of settings to apply to the global php.ini file.
#   Defaults to OS specific defaults (i.e. add nothing)
#

#
class php::global(
  $inifile  = $::php::params::config_root_inifile,
  $settings = {}
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::global is private')
  }

  validate_absolute_path($inifile)
  validate_hash($settings)

  # No deep merging required since the settings we have are the global settings.
  $real_settings = $settings

  ::php::config { 'global':
    file   => $inifile,
    config => $real_settings,
  }
}
