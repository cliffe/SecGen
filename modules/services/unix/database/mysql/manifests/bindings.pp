# @summary
#   Parent class for MySQL bindings.
#
# @example Install Ruby language bindings
#   class { 'mysql::bindings':
#     ruby_enable           => true,
#     ruby_package_ensure   => 'present',
#     ruby_package_name     => 'ruby-mysql-2.7.1-1mdv2007.0.sparc.rpm',
#     ruby_package_provider => 'rpm',
#   }
# @param install_options
#   Passes `install_options` array to managed package resources. You must pass the [appropriate options](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options) for the package manager(s).
# @param java_enable
#   Specifies whether `::mysql::bindings::java` should be included. Valid values are `true`, `false`.
# @param perl_enable
#   Specifies whether `mysql::bindings::perl` should be included. Valid values are `true`, `false`.
# @param php_enable
#   Specifies whether `mysql::bindings::php` should be included. Valid values are `true`, `false`.
# @param python_enable
#   Specifies whether `mysql::bindings::python` should be included. Valid values are `true`, `false`.
# @param ruby_enable
#   Specifies whether `mysql::bindings::ruby` should be included. Valid values are `true`, `false`.
# @param client_dev
#   Specifies whether `::mysql::bindings::client_dev` should be included. Valid values are `true`', `false`.
# @param daemon_dev
#   Specifies whether `::mysql::bindings::daemon_dev` should be included. Valid values are `true`, `false`.
# @param java_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `java_enable => true`.
# @param java_package_name
#   The name of the Java package to install. Only applies if `java_enable => true`.
# @param java_package_provider
#   The provider to use to install the Java package. Only applies if `java_enable => true`.
# @param perl_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `perl_enable => true`.
# @param perl_package_name
#   The name of the Perl package to install. Only applies if `perl_enable => true`.
# @param perl_package_provider
#   The provider to use to install the Perl package. Only applies if `perl_enable => true`.
# @param php_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `php_enable => true`.
# @param php_package_name
#   The name of the PHP package to install. Only applies if `php_enable => true`.
# @param php_package_provider
#   The provider to use to install the PHP package. Only applies if `php_enable => true`.
# @param python_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `python_enable => true`.
# @param python_package_name
#   The name of the Python package to install. Only applies if `python_enable => true`.
# @param python_package_provider
#   The provider to use to install the Python package. Only applies if `python_enable => true`.
# @param ruby_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `ruby_enable => true`.
# @param ruby_package_name
#   The name of the Ruby package to install. Only applies if `ruby_enable => true`.
# @param ruby_package_provider
#   What provider should be used to install the package.
# @param client_dev_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `client_dev => true`.
# @param client_dev_package_name
#   The name of the client_dev package to install. Only applies if `client_dev => true`.
# @param client_dev_package_provider
#   The provider to use to install the client_dev package. Only applies if `client_dev => true`.
# @param daemon_dev_package_ensure
#   Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `daemon_dev => true`.
# @param daemon_dev_package_name
#   The name of the daemon_dev package to install. Only applies if `daemon_dev => true`.
# @param daemon_dev_package_provider
#   The provider to use to install the daemon_dev package. Only applies if `daemon_dev => true`.
#
class mysql::bindings (
  $install_options = undef,
  # Boolean to determine if we should include the classes.
  $java_enable     = false,
  $perl_enable     = false,
  $php_enable      = false,
  $python_enable   = false,
  $ruby_enable     = false,
  $client_dev      = false,
  $daemon_dev      = false,
  # Settings for the various classes.
  $java_package_ensure         = $mysql::params::java_package_ensure,
  $java_package_name           = $mysql::params::java_package_name,
  $java_package_provider       = $mysql::params::java_package_provider,
  $perl_package_ensure         = $mysql::params::perl_package_ensure,
  $perl_package_name           = $mysql::params::perl_package_name,
  $perl_package_provider       = $mysql::params::perl_package_provider,
  $php_package_ensure          = $mysql::params::php_package_ensure,
  $php_package_name            = $mysql::params::php_package_name,
  $php_package_provider        = $mysql::params::php_package_provider,
  $python_package_ensure       = $mysql::params::python_package_ensure,
  $python_package_name         = $mysql::params::python_package_name,
  $python_package_provider     = $mysql::params::python_package_provider,
  $ruby_package_ensure         = $mysql::params::ruby_package_ensure,
  $ruby_package_name           = $mysql::params::ruby_package_name,
  $ruby_package_provider       = $mysql::params::ruby_package_provider,
  $client_dev_package_ensure   = $mysql::params::client_dev_package_ensure,
  $client_dev_package_name     = $mysql::params::client_dev_package_name,
  $client_dev_package_provider = $mysql::params::client_dev_package_provider,
  $daemon_dev_package_ensure   = $mysql::params::daemon_dev_package_ensure,
  $daemon_dev_package_name     = $mysql::params::daemon_dev_package_name,
  $daemon_dev_package_provider = $mysql::params::daemon_dev_package_provider
) inherits mysql::params {

  case $::osfamily {
    'Archlinux': {
      if $java_enable   { fail(translate('::mysql::bindings::java cannot be managed by puppet on %{osfamily}
                          as it is not in official repositories. Please disable java mysql binding.',
                          {'osfamily' => $::osfamily })) }
      if $perl_enable   { include '::mysql::bindings::perl' }
      if $php_enable    { warning(translate('::mysql::bindings::php does not need to be managed by puppet on %{osfamily}
                          as it is included in mysql package by default.',
                          {'osfamily' => $::osfamily })) }
      if $python_enable { include '::mysql::bindings::python' }
      if $ruby_enable   { fail(translate('::mysql::bindings::ruby cannot be managed by puppet on %{osfamily}
                          as it is not in official repositories. Please disable ruby mysql binding.',
                          {'osfamily' => $::osfamily } )) }
    }

    default: {
      if $java_enable   { include '::mysql::bindings::java' }
      if $perl_enable   { include '::mysql::bindings::perl' }
      if $php_enable    { include '::mysql::bindings::php' }
      if $python_enable { include '::mysql::bindings::python' }
      if $ruby_enable   { include '::mysql::bindings::ruby' }
    }
  }

  if $client_dev    { include '::mysql::bindings::client_dev' }
  if $daemon_dev    { include '::mysql::bindings::daemon_dev' }

}
