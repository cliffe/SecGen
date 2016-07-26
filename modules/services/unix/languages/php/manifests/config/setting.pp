# Configure php.ini settings
#
# === Parameters
#
# [*key*]
#   The key of the value, like `ini_setting`
#
# [*file*]
#   The path to ini file
#
# [*value*]
#   The value to set
#
# === Examples
#
#   php::config::setting { 'Date/date.timezone':
#     file  => '$full_path_to_ini_file'
#     value => 'Europe/Berlin'
#   }
#
define php::config::setting(
  $key,
  $value,
  $file,
) {

  if $caller_module_name != $module_name {
    warning('php::config::setting is private')
  }

  validate_string($file)

  $split_name = split($key, '/')
  if count($split_name) == 1 {
    $section = '' # lint:ignore:empty_string_assignment
    $setting = $split_name[0]
  } else {
    $section = $split_name[0]
    $setting = $split_name[1]
  }

  if $value == undef {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  ini_setting { $name:
    ensure  => $ensure,
    value   => $value,
    path    => $file,
    section => $section,
    setting => $setting,
  }
}
