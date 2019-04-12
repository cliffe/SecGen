# @summary
#   Installs and configures the MySQL client.
#
# @example Install the MySQL client
#   class {'::mysql::client':
#     package_name    => 'mysql-client',
#     package_ensure  => 'present',
#     bindings_enable => true,
#   }
#
# @param bindings_enable
#   Whether to automatically install all bindings. Valid values are `true`, `false`. Default to `false`.
# @param install_options
#   Array of install options for managed package resources. You must pass the appropriate options for the package manager.
# @param package_ensure
#   Whether the MySQL package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'.
# @param package_manage
#   Whether to manage the MySQL client package. Defaults to `true`.
# @param package_name
#   The name of the MySQL client package to install.
#
class mysql::client (
  $bindings_enable = $mysql::params::bindings_enable,
  $install_options = undef,
  $package_ensure  = $mysql::params::client_package_ensure,
  $package_manage  = $mysql::params::client_package_manage,
  $package_name    = $mysql::params::client_package_name,
) inherits mysql::params {

  include '::mysql::client::install'

  if $bindings_enable {
    class { 'mysql::bindings':
      java_enable   => true,
      perl_enable   => true,
      php_enable    => true,
      python_enable => true,
      ruby_enable   => true,
    }
  }

  # Anchor pattern workaround to avoid resources of mysql::client::install to
  # "float off" outside mysql::client
  anchor { 'mysql::client::start': }
  -> Class['mysql::client::install']
  -> anchor { 'mysql::client::end': }
}
