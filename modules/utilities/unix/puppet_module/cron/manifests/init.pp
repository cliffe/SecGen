# Class: cron
#
# This class wraps *cron::install* for ease of use
#
# Parameters:
#   manage_package - Can be set to disable package installation.
#     Set to true to manage it, false to not manage it.
#     Default: true
#
#   package_ensure - Can be set to a package version, 'latest', 'installed' or
#     'present'.
#     Default: installed
#
#   package_name - Can be set to install a different cron package.
#     Default: see params.pp
#
#   service_name - Can be set to define a different cron service name.
#     Default: see params.pp
#
#   manage_service - Defines if puppet should manage the service.
#     Default: true
#
#   service_enable - Defines if the service should be enabled at boot.
#     Default: true

#   service_ensure - Defines if the service should be running.
#     Default: running
#
# Sample Usage:
#   include 'cron'
# or:
#   class { 'cron':
#     manage_package => false,
#   }
#
class cron (
  String[1]      $service_name,
  String[1]      $package_name,
  Boolean        $manage_package = true,
  Boolean        $manage_service = true,
  Variant[
    Boolean,
    Enum[
      'running',
      'stopped',
    ]
  ]              $service_ensure = 'running',
  Variant[
    Boolean,
    Enum[
      'manual',
      'mask',
    ]
  ]              $service_enable = true,
  String[1]      $package_ensure = 'installed',
  Array[String]  $users_allow    = [],
  Array[String]  $users_deny     = [],
  Boolean        $manage_users_allow = false,
  Boolean        $manage_users_deny  = false,
) {

  contain '::cron::install'
  contain '::cron::service'

  Class['cron::install'] -> Class['cron::service']

  # Manage cron.allow and cron.deny
  if $manage_users_allow {
    file { '/etc/cron.allow':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      content => epp('cron/users.epp', { 'users' => $users_allow }),
    }
  }

  if $manage_users_deny {
    file { '/etc/cron.deny':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      content => epp('cron/users.epp', { 'users' => $users_deny }),
    }
  }


  # Create jobs from hiera

  $cron_job = lookup('cron::job', Optional[Hash], 'hash', {})
  $cron_job.each | String $t, Hash $params | {
    cron::job { $t:
      * => $params,
    }
  }

  $cron_job_multiple = lookup('cron::job::multiple', Optional[Hash], 'hash', {})
  $cron_job_multiple.each | String $t, Hash $params | {
    cron::job::multiple { $t:
      * => $params,
    }
  }

  $cron_hourly = lookup('cron::hourly', Optional[Hash], 'hash', {})
  $cron_hourly.each | String $t, Hash $params | {
    cron::hourly { $t:
      * => $params,
    }
  }

  $cron_daily = lookup('cron::daily', Optional[Hash], 'hash', {})
  $cron_daily.each | String $t, Hash $params | {
    cron::daily { $t:
      * => $params,
    }
  }

  $cron_weekly = lookup('cron::weekly', Optional[Hash], 'hash', {})
  $cron_weekly.each | String $t, Hash $params | {
    cron::weekly { $t:
      * => $params,
    }
  }

  $cron_monthly = lookup('cron::monthly', Optional[Hash], 'hash', {})
  $cron_monthly.each | String $t, Hash $params | {
    cron::monthly { $t:
      * => $params,
    }
  }

}
