# Install and configure php CLI
#
# === Parameters
#
# [*inifile*]
#   The path to the ini php5-cli ini file
#
# [*settings*]
#   Hash with nested hash of key => value to set in inifile
#
class php::cli(
  $inifile  = $::php::params::cli_inifile,
  $settings = {}
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::cli is private')
  }

  validate_absolute_path($inifile)
  validate_hash($settings)

  $real_settings = deep_merge($settings, hiera_hash('php::cli::settings', {}))

  ::php::config { 'cli':
    file   => $inifile,
    config => $real_settings,
  }
}
