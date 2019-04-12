# Class: ruby
#
# This class installs Ruby and manages rubygems
#
# Parameters:
#
#  version: (default installed)
#    Set the version of Ruby to install
#
#  gems_version: (default installed)
#    Set the version of Rubygems to be installed
#
#  rubygems_update: (default false)
#    If set to true, the module will ensure that the rubygems package is
#    installed but will use rubygems-update (same as gem update --system
#    but versionable) to update Rubygems to the version defined in
#    $gems_version. If set to false then the rubygems package resource
#    will be versioned from $gems_version
#
#  ruby_package: (default ruby)
#    Set the package name for ruby
#
#  rubygems_package: (default rubygems)
#    Set the package name for rubygems
#
# Actions:
#   - Install Ruby
#   - Install Rubygems
#   - Optionally Update Rubygems
#
# Requires:
#
# Sample Usage:
#
#  For a standard install using the latest Rubygems provided by
#  rubygems *without update* on Redhat use:
#
#    class { 'ruby':
#      gems_version  => 'latest',
#    }
#
#  On Redhat this is equivalent to
#    $ yum install ruby rubygems
#
#  To install a specific version of ruby and then call
#  gem update, use:
#
#    class { 'ruby':
#      version         => '1.8.7',
#      rubygems_update => true,
#    }
#
#  On RedHat this is equivalent to
#    $ yum install ruby-1.8.7 rubygems
#    $ gem update --system
#
#  To install a specific version of ruby and rubygems
#  use:
#
#    class { 'ruby':
#      version         => '1.8.7',
#      gems_version    => '1.8.24',
#      rubygems_update => true,
#    }
#
#  On Redhat this is equivalent to
#    $ yum install ruby-1.8.7 rubygems-1.8.24
#    $ gem update --system
#
#  If you need to use different packages for either ruby or rubygems you
#  can. This could be for different versions or custom packages. For instance
#  the following installs ruby 1.9 on Ubuntu 12.04.
#
#    class { 'ruby':
#      ruby_package     => 'ruby1.9.1-full',
#      rubygems_package => 'rubygems1.9.1',
#      gems_version     => 'latest',
#    }
#
# Ruby package names are not straightforward. Especially in Debian
# osfamily Linux distributions
# ruby is a virtual package that points to ruby1.8
# ruby1.8 installs Ruby 1.8.7 (and earlier versions), requires a PPA for 14.04 or later
# ruby1.9.1 installs Ruby 1.9.x
# ruby1.9.1-full installs Ruby 1.9.x
# ruby1.9.3 installs Ruby 1.9.x
# Ruby 2.0.0 is availible from a PPA or Ubuntu 13.10 or later.
# Ruby 2.1.0 is availible from a PPA.
# ...and this should all be overridden if a package is specified
#
class ruby (
  $version                  = $ruby::params::version,
  $latest_release           = undef,
  $gems_version             = $ruby::params::gems_version,
  $rubygems_update          = $ruby::params::rubygems_update,
  $ruby_package             = $ruby::params::ruby_package,
  $ruby_dev_packages        = $ruby::params::ruby_dev,
  $rubygems_package         = $ruby::params::rubygems_package,
  $suppress_warnings        = false,
  $set_system_default       = false,
  $system_default_bin       = undef,
  $system_default_gem       = undef,
  $gem_integration          = false,
  $gem_integration_package  = $ruby::params::gem_integration_package,
  $switch                   = undef
) inherits ruby::params {

  if $latest_release {
    $ruby_package_ensure = 'latest'
  } else {
    $ruby_package_ensure = 'installed'
  }

  case $::osfamily {
    'Debian': {
      case $ruby_package {
        'installed': {
          $real_ruby_package = $ruby_package
        }
        default:{
          case $version {
            /^1\.8.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}1.8"
              if ! $suppress_warnings and versioncmp($::operatingsystemrelease, '14.04') >= 0 {
                warning('Packages for Ruby 1.8 are not available from default repositories.')
              }
            }
            /^1\.9.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}1.9.1"
            }
            /^2\.0.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}2.0"
              if ! $suppress_warnings and versioncmp($::operatingsystemrelease, '13.10') < 0 {
                warning('Packages for Ruby 2.0 are not available from default repositories.')
              }
            }
            /^2\.1.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}2.1"
              if ! $suppress_warnings {
                warning('Packages for Ruby 2.1 are not available from default repositories.')
              }
            }
            default: {
              $real_ruby_package  = $ruby_package
            }
          }
        }
      }
    }
    default: {
      $real_ruby_package  = $ruby_package
    }
  }

  # The "version" switch seems to do nothing on a non-Debian distro. This is
  # probably the safest behavior for the moment, since RedHat doesn't change
  # the ruby package name the way Debian does when new versions become
  # available. It's a bit misleading for the user, though, since they can
  # specify a version and it will just silently continue installing the
  # default version.
  package { 'ruby':
    ensure => $ruby_package_ensure,
    name   => $real_ruby_package,
  }

  # if rubygems_update is set to true then we only need to make the package
  # resource for rubygems ensure to installed, we'll let rubygems-update
  # take care of the versioning.

  if $rubygems_update == true {
    $rubygems_ensure = 'installed'
  } else {
    $rubygems_ensure = $gems_version
  }

  if $rubygems_package {
    package { 'rubygems':
      ensure  => $rubygems_ensure,
      name    => $rubygems_package,
      require => Package['ruby'],
    }
  }

  if $rubygems_update {
    package { 'rubygems-update':
      ensure   => $gems_version,
      provider => 'gem',
      require  => Package['rubygems'],
      notify   => Exec['ruby::update_rubygems'],
    }

    exec { 'ruby::update_rubygems':
      path        => '/usr/local/bin:/usr/bin:/bin',
      command     => 'update_rubygems',
      refreshonly => true,
    }
  }

  if $set_system_default or $switch {
    case $::osfamily {
      'Debian': {
        if $system_default_bin {
          $real_default_bin = $system_default_bin
        } else {
          case $version {
            /^1\.8.*$/:{
              $real_default_bin  = "${ruby::params::ruby_bin_base}1.8"
              if ! $suppress_warnings and versioncmp($::operatingsystemrelease, '14.04') >= 0 {
                warning('No binary for Ruby 1.8.x available from default repositories')
              }
            }
            /^1\.9.*$/:{
              $real_default_bin  = "${ruby::params::ruby_bin_base}1.9.1"
            }
            /^2\.0.*$/:{
              $real_default_bin  = "${ruby::params::ruby_bin_base}2.0"
              if ! $suppress_warnings and versioncmp($::operatingsystemrelease, '13.10') < 0 {
                warning('No binary for Ruby 2.0.x available from default repositories')
              }
            }
            /^2\.1.*$/:{
              $real_default_bin  = "${ruby::params::ruby_bin_base}2.1"
              if ! $suppress_warnings {
                warning('No binary for Ruby 2.1.x available from default repositories')
              }
            }
            default: {
              fail('Unable to resolve default ruby binary')
            }
          }
        }
        if $system_default_gem {
          $real_default_gem = $system_default_gem
        } else {
          case $version {
            /^1\.8.*$/:{
              $real_default_gem  = "${ruby::params::ruby_gem_base}1.8"
              if ! $suppress_warnings and versioncmp($::operatingsystemrelease, '14.04') >= 0 {
                warning('No binary package for Ruby 1.8.x available from default repositories')
              }
            }
            /^1\.9.*$/:{
              $real_default_gem  = "${ruby::params::ruby_gem_base}1.9.1"
            }
            /^2\.0.*$/:{
              $real_default_gem  = "${ruby::params::ruby_gem_base}2.0"
              if ! $suppress_warnings and versioncmp($::operatingsystemrelease, '13.10') < 0 {
                warning('No binary package for Ruby 2.0.x available from default repositories')
              }
            }
            /^2\.1.*$/:{
              $real_default_gem  = "${ruby::params::ruby_gem_base}2.1"
              if ! $suppress_warnings {
                warning('No binary package for Ruby 2.1.x available from default repositories')
              }
            }
            default: {
              fail('Unable to resolve default gem binary')
            }
          }
        }
        # update-alternatives does not support ruby in 14.04!
        file{'ruby_bin':
          ensure  => link,
          path    => $::ruby::params::ruby_bin_base,
          target  => $real_default_bin,
          require => Package['ruby'],
        }
        # This should notify Exec['ruby::update_rubygems'] but if rubygems_update is false
        # it doesn't exist.
        file{'gem_bin':
          ensure  => link,
          path    => $::ruby::params::ruby_gem_base,
          target  => $real_default_gem,
          require => Package['rubygems'],
        }
      }
      default: {
        if $switch {
          warning('The switch parameter is depreciated, use set_system_default')
          notice("The switch parameter for the ruby class does not work for ${::operatingsystem}, no action taken.")
        }
        if $set_system_default {
          notice("The set_system_default parameter for the ruby class does not work for ${::operatingsystem}, no action taken.")
        }
      }
    }
  }

  if $gem_integration {
    case $::osfamily {
      'Debian': {
        if ! $suppress_warnings and $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.04') < 0 {
          warning('No package for rubygems_integration available from default repositories')
        }
        package{'rubygems_integration':
          ensure  => $ruby_package_ensure,
          name    => $gem_integration_package,
          require => Package['rubygems'],
        }
      }
      default: {
        notice("The gem_integration parameter for the ruby class does not work for ${::operatingsystem}, no action taken.")
      }
    }
  }
}
