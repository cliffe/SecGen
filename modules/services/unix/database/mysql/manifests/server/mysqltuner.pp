# @summary
#   Manage the MySQLTuner package.
#
# @param ensure
#   Ensures that the resource exists. Valid values are 'present', 'absent'. Defaults to 'present'.
# @param version
#   The version to install from the major/MySQLTuner-perl github repository. Must be a valid tag. Defaults to 'v1.3.0'.
# @param source
#   Source path for the mysqltuner package.
# @param environment
#   Environment variables active during download, e.g. to download via proxies: environment => 'https_proxy=http://proxy.example.com:80'
#
class mysql::server::mysqltuner(
  $ensure  = 'present',
  $version = 'v1.3.0',
  $source  = undef,
  $environment = undef, # environment for staging::file
) {

  if $source {
    $_version = $source
    $_source  = $source
  } else {
    $_version = $version
    $_source  = "https://github.com/major/MySQLTuner-perl/raw/${version}/mysqltuner.pl"
  }

  if $ensure == 'present' {
    # $::puppetversion doesn't exist in puppet 4.x so would break strict
    # variables
    if ! $::settings::strict_variables {
      $_puppetversion = $::puppetversion
    } else {
      # defined only works with puppet >= 3.5.0, so don't use it unless we're
      # actually using strict variables
      $_puppetversion = defined('$puppetversion') ? {
        true    => $::puppetversion,
        default => undef,
      }
    }
    # see https://tickets.puppetlabs.com/browse/ENTERPRISE-258
    if $_puppetversion and $_puppetversion =~ /Puppet Enterprise/ and versioncmp($_puppetversion, '3.8.0') < 0 {
      class { '::staging':
        path => '/opt/mysql_staging',
      }
    } else {
      class { '::staging': }
    }

    staging::file { "mysqltuner-${_version}":
      source      => $_source,
      environment => $environment,
    }
    file { '/usr/local/bin/mysqltuner':
      ensure  => $ensure,
      mode    => '0550',
      source  => "${::staging::path}/mysql/mysqltuner-${_version}",
      require => Staging::File["mysqltuner-${_version}"],
    }
  } else {
    file { '/usr/local/bin/mysqltuner':
      ensure => $ensure,
    }
  }
}
