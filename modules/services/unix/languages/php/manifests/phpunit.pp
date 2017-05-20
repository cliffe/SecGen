# Install phpunit, PHP testing framework
#
# === Parameters
#
# [*source*]
#   Holds URL to the phpunit source file
#
# [*path*]
#   Holds path to the phpunit executable
#
# [*auto_update*]
#   Defines if phpunit should be auto updated
#
# [*max_age*]
#   Defines the time in days after which an auto-update gets executed
#
class php::phpunit (
  $source      = $::php::params::phpunit_source,
  $path        = $::php::params::phpunit_path,
  $auto_update = true,
  $max_age     = $::php::params::phpunit_max_age,
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::phpunit is private')
  }

  validate_string($source)
  validate_absolute_path($path)
  validate_bool($auto_update)
  validate_re("x${max_age}", '^x\d+$')

  ensure_packages(['wget'])

  exec { 'download phpunit':
    command => "wget ${source} -O ${path}",
    creates => $path,
    path    => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
    require => [Class['::php::cli'],Package['wget']],
  } ->
  file { $path:
    mode  => '0555',
    owner => root,
    group => root,
  }

  if $auto_update {
    class { '::php::phpunit::auto_update':
      max_age => $max_age,
      source  => $source,
      path    => $path,
    }
  }
}
