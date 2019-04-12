class ntp (
  $autoupdate        = $ntp::params::autoupdate,
  $broadcastclient   = $ntp::params::broadcastclient,
  $config            = $ntp::params::config,
  $config_dir        = $ntp::params::config_dir,
  $config_file_mode  = $ntp::params::config_file_mode,
  $config_template   = $ntp::params::config_template,
  $disable_auth      = $ntp::params::disable_auth,
  $disable_dhclient  = $ntp::params::disable_dhclient,
  $disable_kernel    = $ntp::params::disable_kernel,
  $disable_monitor   = $ntp::params::disable_monitor,
  $fudge             = $ntp::params::fudge,
  $driftfile         = $ntp::params::driftfile,
  $leapfile          = $ntp::params::leapfile,
  $logfile           = $ntp::params::logfile,
  $iburst_enable     = $ntp::params::iburst_enable,
  $keys              = $ntp::params::keys,
  $keys_enable       = $ntp::params::keys_enable,
  $keys_file         = $ntp::params::keys_file,
  $keys_controlkey   = $ntp::params::keys_controlkey,
  $keys_requestkey   = $ntp::params::keys_requestkey,
  $keys_trusted      = $ntp::params::keys_trusted,
  $minpoll           = $ntp::params::minpoll,
  $maxpoll           = $ntp::params::maxpoll,
  $package_ensure    = $ntp::params::package_ensure,
  $package_manage    = $ntp::params::package_manage,
  $package_name      = $ntp::params::package_name,
  $panic             = $ntp::params::panic,
  $peers             = $ntp::params::peers,
  $preferred_servers = $ntp::params::preferred_servers,
  $restrict          = $ntp::params::restrict,
  $interfaces        = $ntp::params::interfaces,
  $interfaces_ignore = $ntp::params::interfaces_ignore,
  $servers           = $ntp::params::servers,
  $service_enable    = $ntp::params::service_enable,
  $service_ensure    = $ntp::params::service_ensure,
  $service_manage    = $ntp::params::service_manage,
  $service_name      = $ntp::params::service_name,
  $service_provider  = $ntp::params::service_provider,
  $stepout           = $ntp::params::stepout,
  $tinker            = $ntp::params::tinker,
  $tos               = $ntp::params::tos,
  $tos_minclock      = $ntp::params::tos_minclock,
  $tos_minsane       = $ntp::params::tos_minsane,
  $tos_floor         = $ntp::params::tos_floor,
  $tos_ceiling       = $ntp::params::tos_ceiling,
  $tos_cohort        = $ntp::params::tos_cohort,
  $udlc              = $ntp::params::udlc,
  $udlc_stratum      = $ntp::params::udlc_stratum,
  $ntpsigndsocket    = $ntp::params::ntpsigndsocket,
  $authprov          = $ntp::params::authprov,
) inherits ntp::params {

  validate_bool($broadcastclient)
  validate_absolute_path($config)
  validate_string($config_template)
  validate_bool($disable_auth)
  validate_bool($disable_dhclient)
  validate_bool($disable_kernel)
  validate_bool($disable_monitor)
  validate_absolute_path($driftfile)
  if $logfile { validate_absolute_path($logfile) }
  if $ntpsigndsocket { validate_absolute_path($ntpsigndsocket) }
  if $leapfile { validate_absolute_path($leapfile) }
  validate_bool($iburst_enable)
  validate_array($keys)
  validate_bool($keys_enable)
  validate_re($keys_controlkey, ['^\d+$', ''])
  validate_re($keys_requestkey, ['^\d+$', ''])
  validate_array($keys_trusted)
  if $minpoll { validate_numeric($minpoll, 16, 3) }
  if $maxpoll { validate_numeric($maxpoll, 16, 3) }
  validate_string($package_ensure)
  validate_bool($package_manage)
  validate_array($package_name)
  if $panic { validate_numeric($panic, 65535, 0) }
  validate_array($preferred_servers)
  validate_array($restrict)
  validate_array($interfaces)
  validate_array($servers)
  validate_array($fudge)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)
  if $stepout { validate_numeric($stepout, 65535, 0) }
  validate_bool($tinker)
  validate_bool($tos)
  if $tos_minclock { validate_numeric($tos_minclock) }
  if $tos_minsane { validate_numeric($tos_minsane) }
  if $tos_floor { validate_numeric($tos_floor) }
  if $tos_ceiling { validate_numeric($tos_ceiling) }
  if $tos_cohort { validate_re($tos_cohort, '^[0|1]$', "Must be 0 or 1, got: ${tos_cohort}") }
  validate_bool($udlc)
  validate_array($peers)
  if $authprov { validate_string($authprov) }

  if $config_dir {
    validate_absolute_path($config_dir)
  }

  if $autoupdate {
    notice('autoupdate parameter has been deprecated and replaced with package_ensure.  Set this to latest for the same behavior as autoupdate => true.')
  }

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up.  You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'ntp::begin': } ->
  class { '::ntp::install': } ->
  class { '::ntp::config': } ~>
  class { '::ntp::service': } ->
  anchor { 'ntp::end': }

}
