class apache::mod::shib (
  $suppress_warning = false,
  $mod_full_path    = undef,
  $package_name     = undef,
  $mod_lib          = undef,
) {
  include ::apache
  if $::osfamily == 'RedHat' and ! $suppress_warning {
    warning('RedHat distributions do not have Apache mod_shib in their default package repositories.')
  }

  $mod_shib = 'shib2'

  apache::mod {$mod_shib:
    id      => 'mod_shib',
    path    => $mod_full_path,
    package => $package_name,
    lib     => $mod_lib,
  }
}
