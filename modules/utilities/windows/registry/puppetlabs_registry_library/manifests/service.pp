# Define: registry::service
#
#   This defined resource type manages service entries in the Microsoft service
#   control framework by managing the appropriate registry keys and values.
#
#   This is an alternative approach to using INSTSRV.EXE [1].
#
#   [1] http://support.microsoft.com/kb/137890
#
# Parameters:
#
#   ensure: [ present, absent ]
#
#   display_name: The Display Name of the service.  Defaults to the title of
#   the resource.
#
#   description: A description of the service
#
#   command: The command to execute
#
#   start: The starting mode of the service.  (Note, the native service
#   resource can also be used to manage this setting.)
#   [ automatic, manual, disabled ]
#
# Actions:
#
#   Manages the values in the key HKLM\System\CurrentControlSet\Services\$name\
#
# Requires:
#
#   Module puppetlabs-registry
#
# Sample Usage:
#
#   registry::service { puppet:
#     ensure       => present,
#     display_name => 'Puppet Agent',
#     description  => 'Periodically fetches and applies
#                   configurations from a Puppet master server.',
#     command      => 'C:\PuppetLabs\Puppet\service\daemon.bat',
#   }
#
define registry::service(
  $ensure       = 'UNSET',
  $display_name = 'UNSET',
  $description  = 'UNSET',
  $command      = 'UNSET',
  $start        = 'UNSET'
) {

  $ensure_real = $ensure ? {
    'UNSET'  => present,
    undef   => present,
    present => present,
    absent  => absent,
  }

  $display_name_real = $display_name ? {
    'UNSET' => $name,
    default => $display_name,
  }

  $description_real = $description ? {
    'UNSET' => $display_name_real,
    default => $description,
  }

  # FIXME Better validation of the command parameter.
  # (Fully qualified path?  Though, it will be a REG_EXPAND_SZ.)
  $command_real = $command ? {
    default => $command,
  }

  # Map descriptive names to flags.
  $start_real = $start ? {
    automatic => 2,
    manual    => 3,
    disabled  => 4,
  }

  # Variable to hold the base key path.
  $service_key = "HKLM\\System\\CurrentControlSet\\Services\\${name}"

  # Manage the key
  if $ensure_real == present {
    registry_key { $service_key:
      ensure => present,
    }
  } else {
    registry_key { $service_key:
      ensure => absent,
      # REVISIT: purge_values => true,
    }
  }

  # Manage the values
  if $ensure_real == present {
    registry_value { "${service_key}\\Description":
      ensure => present,
      type   => string,
      data   => $description_real,
    }
    registry_value { "${service_key}\\DisplayName":
      ensure => present,
      type   => string,
      data   => $display_name_real,
    }
    registry_value { "${service_key}\\ErrorControl":
      ensure => present,
      type   => dword,
      data   => 0x00000001,
    }
    registry_value { "${service_key}\\ImagePath":
      ensure => present,
      type   => expand,
      data   => $command_real,
    }
    registry_value { "${service_key}\\ObjectName":
      ensure => present,
      type   => string,
      data   => 'LocalSystem',
    }
    registry_value { "${service_key}\\Start":
      ensure => present,
      type   => dword,
      data   => $start_real,
    }
    registry_value { "${service_key}\\Type":
      ensure => present,
      type   => dword,
      data   => 0x00000010, # (16)
    }
  }
}
# EOF
