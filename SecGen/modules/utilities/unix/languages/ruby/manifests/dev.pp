# Class: ruby::dev
#
# This class installs Ruby development libraries. It's not right, and has no tests.
#
# Parameters:
#
# [*ensure*]
# (default is 'installed') This parameter sets the `ensure` parameter for all the Ruby development packages.
# [*ruby_dev_packages*]
# (default is depends on OS distribution) This parameter replaces the list of default Ruby development packages.
# [*rake_ensure*]
# (default is 'installed') This sets the `ensure` parameter of the rake package.
# [*rake_package*]
# (default depends on OS distribution) This parameter replaces the default rake package.
# [*rake_provider*]
# (default depends on OS distribution) This parameter replaces the default rake provider.
# [*bundler_ensure*]
# (default is 'installed') This sets the `ensure` parameter of the bundler package.
# [*bundler_package*]
# (default is depends on OS distribution) This parameter replaces the default bundler package.
# [*bundler_provider*]
# (default depends on OS distribution) This parameter replaces the default bundler provider.
#
# Actions:
#   - Install RDoc, IRB, and development libraries
#   - Optionally install Rake and Bundler (installed by default)
#
# Requires:
#
#   - Ruby
#
# Sample Usage:
#
# include ruby
# include ruby::dev
#
class ruby::dev (
  Enum['installed', 'present', 'absent', 'latest'] $ensure  = 'installed',
  $ruby_dev_packages                                        = undef,
  $rake_ensure                                              = $ruby::params::rake_ensure,
  $rake_package                                             = $ruby::params::rake_package,
  $rake_provider                                            = $ruby::params::rake_provider,
  $bundler_ensure                                           = $ruby::params::bundler_ensure,
  $bundler_package                                          = $ruby::params::bundler_package,
  Enum['gem', 'apt', 'pacman'] $bundler_provider            = $ruby::params::bundler_provider,
) inherits ruby::params {
  require ::ruby

  case $::osfamily {
    default: {
      fail("Detected osfamily is <${::osfamily}> and supported values are 'Debian', 'RedHat', 'Archlinux' and 'Amazon'")
    }
    'Debian': {
      if $ruby_dev_packages {
        $ruby_dev = $ruby_dev_packages
      } else {
        case $::ruby::version {
          /^1\.8.*$/:{
            $ruby_dev = [
              'ruby1.8-dev',
              'ri1.8',
              'pkg-config',
            ]
          }
          /^1\.9.*$/:{
            $ruby_dev = [
              'ruby1.9.1-dev',
              'ri1.9.1',
              'pkg-config',
            ]
          }
          /^2\.0.*$/:{
            $ruby_dev = [
              'ruby2.0-dev',
              'ri',
              'pkg-config',
            ]
          }
          /^2\.1.*$/:{
            $ruby_dev = [
              'ruby2.1-dev',
              'ri',
              'pkg-config',
            ]
          }
          default: {
            $ruby_dev = $::ruby::params::ruby_dev
          }
        }
      }
    }
    'RedHat', 'Amazon': {
      # This specifically covers the case where there is no distro-provided
      # package for bundler. We install it using gem instead. Right now, this is
      # only set on RedHat and Amazon (see params.pp).
      $ruby_dev_gems = $::ruby::params::ruby_dev_gems

      if $ruby_dev_packages {
        $ruby_dev = $ruby_dev_packages
      } else {
        $ruby_dev = $::ruby::params::ruby_dev
      }
    }
    'Archlinux': {
      $ruby_dev_gems = undef
      $ruby_dev = undef
    }
  }

  # The "version" switch seems to do nothing on a non-Debian distro. This is
  # probably the safest behavior for the moment, since RedHat doesn't change
  # the ruby package name the way Debian does when new versions become
  # available. It's a bit misleading for the user, though, since they can
  # specify a version and it will just silently continue installing the
  # default version.
  if $ruby_dev {
    package { $ruby_dev:
      ensure  => $ensure,
      before  => Package['rake', 'bundler'],
      require => Package['ruby'],
    }
  }

  if $rake_package {
    package { 'rake':
      ensure   => $rake_ensure,
      name     => $rake_package,
      provider => $rake_provider,
      require  => Package['ruby'],
    }
  }

  if $bundler_package {
    package { 'bundler':
      ensure   => $bundler_ensure,
      name     => $bundler_package,
      provider => $bundler_provider,
      require  => Package['ruby'],
    }
  }

  if $ruby_dev_gems {
    package { $ruby_dev_gems:
      ensure   => $ensure,
      provider => gem,
    }
  }

}
