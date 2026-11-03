# ntp
#
# Main class, includes all other classes.
#
# @param authprov
#   Enables compatibility with W32Time in some versions of NTPd (such as Novell DSfW). Default value: undef.
#
# @param broadcastclient
#   Enables reception of broadcast server messages to any local interface. Default value: false.
#
# @param burst
#   When the server is reachable, send a burst of eight packets instead of the usual one. Default value: false.
#
# @param config
#   Specifies a file for NTP's configuration info. Default value: '/etc/ntp.conf' (or '/etc/inet/ntp.conf' on Solaris).
#
# @param config_dir
#   Specifies a directory for the NTP configuration files. Default value: undef.
#
# @param config_epp
#   Specifies an absolute or relative file path to an EPP template for the config file.
#   Example value: 'ntp/ntp.conf.epp'. A validation error is thrown if both this **and** the `config_template` parameter are specified.
#
# @param config_file_mode
#   Specifies a file mode for the ntp configuration file. Default value: '0664'.
#
# @param config_template
#   Specifies an absolute or relative file path to an ERB template for the config file.
#   Example value: 'ntp/ntp.conf.erb'. A validation error is thrown if both this **and** the `config_epp` parameter are specified.
#
# @param daemon_extra_opts
#   Specifies any arguments to pass to ntp daemon. Default value: '-g'.
#   Example value: '-g -i /var/lib/ntp' to enable jaildir options.
#   Note that user is a specific parameter handled separately.
#
# @param disable_auth
#   Disables cryptographic authentication for broadcast client, multicast client, and symmetric passive associations.
#
# @param disable_dhclient
#   Disables `ntp-servers` in `dhclient.conf` to prevent Dhclient from managing the NTP configuration.
#
# @param disable_kernel
#   Disables kernel time discipline.
#
# @param disable_monitor
#   Disables the monitoring facility in NTP. Default value: true.
#
# @param driftfile
#   Specifies an NTP driftfile. Default value: '/var/lib/ntp/drift' (except on AIX and Solaris).
#
# @param enable_mode7
#   Enables processing of NTP mode 7 implementation-specific requests which are used by the deprecated ntpdc program. Default value: false.
#
# @param fudge
#   Provides additional information for individual clock drivers. Default value: [ ]
#
# @param iburst_enable
#   Specifies whether to enable the iburst option for every NTP peer. Default value: false (true on AIX and Debian).
#
# @param interfaces
#   Specifies one or more network interfaces for NTP to listen on. Default value: [ ].
#
# @param interfaces_ignore
#   Specifies one or more ignore pattern for the NTP listener configuration (for example: all, wildcard, ipv6). Default value: [ ].
#
# @param keys
#   Distributes keys to keys file. Default value: [ ].
#
# @param keys_controlkey
#   Specifies the key identifier to use with the ntpq utility. Value in the range of 1 to 65,534 inclusive. Default value: ' '.
#
# @param keys_enable
#   Whether to enable key-based authentication. Default value: false.
#
# @param keys_file
#   Specifies the complete path and location of the MD5 key file containing the keys and key identifiers used by ntpd, ntpq and ntpdc
#   when operating with symmetric key cryptography. Default value: `/etc/ntp.keys` (on RedHat and Amazon, `/etc/ntp/keys`).
#
# @param keys_requestkey
#   Specifies the key identifier to use with the ntpdc utility program. Value in the range of 1 to 65,534. Default value: ' '.
#
# @param keys_trusted
#   Provides one or more keys to be trusted by NTP. Default value: [ ].
#
# @param leapfile
#   Specifies a leap second file for NTP to use. Default value: ' '.
#
# @param logfile
#   Specifies a log file for NTP to use instead of syslog. Default value: ' '.
#
# @param logfile_group
#   Specifies the group for the NTP log file. Default is 'ntp'.
#
# @param logfile_mode
#   Specifies the permission for the NTP log file. Default is 0664.
#
# @param logfile_user
#   Specifies the user for the NTP log file. Default is 'ntp'.
#
# @param logconfig
#   Specifies the logconfig for NTP to use. Default value: ' '.
#
# @param minpoll
#   Sets Puppet to non-standard minimal poll interval of upstream servers.
#   Values: 3 to 16. Default: undef.
#
# @param maxpoll
#   Sets use non-standard maximal poll interval of upstream servers.
#   Values: 3 to 16. Default option: undef, except on FreeBSD (on FreeBSD, defaults to 9).
#
# @param ntpsigndsocket
#   Sets NTP to sign packets using the socket in the ntpsigndsocket path. Requires NTP to be configured to sign sockets.
#   Value: Path to the socket directory; for example, for Samba: `usr/local/samba/var/lib/ntp_signd/`. Default value: undef.
#
# @param package_ensure
#   Whether to install the NTP package, and what version to install. Values: 'present', 'latest', or a specific version number.
#   Default value: 'present'.
#
# @param package_manage
#   Whether to manage the NTP package. Default value: true.
#
# @param package_name
#   Specifies the NTP package to manage. Default value: ['ntp'] (except on AIX and Solaris).
#
# @param panic
#   Whether NTP should "panic" in the event of a very large clock skew. Applies only if `tinker` option set to true or if your environment
#   is in a virtual machine. Default value: 0 if environment is virtual, undef in all other cases.
#
# @param peers
#   List of NTP servers with which to synchronise the local clock.
#
# @param tos_orphan
#   Enables Orphan mode for peer group
#   Value: Should be set to 2 more than the worst-case externally-reachable source's stratum.
#
# @param pool
#   List of NTP server pools with which to synchronise the local clock.
#
# @param preferred_servers
#   Specifies one or more preferred peers. Puppet appends 'prefer' to each matching item in the `servers` array.
#   Default value: [ ].
#
# @param noselect_servers
#   Specifies one or more peers to not sync with. Puppet appends 'noselect' to each matching item in the `servers` array.
#   Default value: [ ].
#
# @param restrict
#   Specifies one or more `restrict` options for the NTP configuration.
#   Puppet prefixes each item with 'restrict', so you need to list only the content of the restriction.
#   Default value for most operating systems:
#     '[default kod nomodify notrap nopeer noquery', '-6 default kod nomodify notrap nopeer noquery', '127.0.0.1', '-6 ::1']'.
#   Default value for AIX systems:
#     '['default nomodify notrap nopeer noquery', '127.0.0.1',]'.
#
# @param servers
#   Specifies one or more servers to be used as NTP peers. Default value: varies by operating system.
#
# @param service_enable
#   Whether to enable the NTP service at boot. Default value: true.
#
# @param service_ensure
#   Whether the NTP service should be running. Default value: 'running'.
#
# @param service_manage
#   Whether to manage the NTP service.  Default value: true.
#
# @param service_name
#   The NTP service to manage. Default value: varies by operating system.
#
# @param service_provider
#   Which service provider to use for NTP. Default value: 'undef'.
#
# @param service_hasstatus
#   Whether service has a functional status command. Default value: true.
#
# @param service_hasrestart
#   Whether service has a restart command. Default value: true.
#
# @param slewalways
#   xntpd setting to disable stepping behavior and always slew the clock to handle adjustments.
#   Only relevant for AIX. Default value: 'undef'. Allowed values: 'yes', 'no'
#
# @param statistics
#   List of statistics to have NTP generate and keep. Default value: [ ].
#
# @param statsdir
#   Location of the NTP statistics directory on the managed system. Default value: '/var/log/ntpstats'.
#
# @param step_tickers_file
#   Location of the step tickers file on the managed system. Default value: varies by operating system.
#
# @param step_tickers_epp
#   Location of the step tickers EPP template file. Default value: varies by operating system.
#   Validation error is thrown if both this and the `step_tickers_template` parameters are specified.
#
# @param step_tickers_template
#   Location of the step tickers ERB template file. Default value: varies by operating system.
#   Validation error is thrown if both this and the `step_tickers_epp` parameter are specified.
#
# @param stepout
#   Value for stepout if `tinker` value is true. Valid options: unsigned shortint digit. Default value: undef.
#
# @param tos
#   Whether to enable tos options. Default value: false.
#
# @param tos_minclock
#   Specifies the minclock tos option. Default value: 3.
#
# @param tos_maxclock
#   Specifies the maxclock tos option. Default value: 6.
#
# @param tos_minsane
#   Specifies the minsane tos option. Default value: 1.
#
# @param tos_floor
#   Specifies the floor tos option. Default value: 1.
#
# @param tos_ceiling
#   Specifies the ceiling tos option. Default value: 15.
#
# @param tos_cohort
#   Specifies the cohort tos option. Valid options: 0 or 1. Default value: 0.
#
# @param tinker
#   Whether to enable tinker options. Default value: false.
#
# @param udlc
#   Specifies whether to configure NTP to use the undisciplined local clock as a time source. Default value: false.
#
# @param udlc_stratum
#   Specifies the stratum the server should operate at when using the undisciplined local clock as the time source.
#   This value should be set to no less than 10 if ntpd might be accessible outside your immediate, controlled network.
#   Default value: 10.am udlc
#
# @param user
#   Specifies user to run ntpd daemon. Default value: ntp.
#   Usually set by default on Centos7 (/etc/systemd/system/multi-user.target.wants/ntpd.service) and ubuntu 18.04 (/usr/lib/ntp/ntp-systemd-wrapper)
#   This is currently restricted to Redhat based systems of version 7 and above and Ubuntu 18.04.
#
class ntp (
  Boolean                             $broadcastclient,
  Boolean                             $burst,
  Stdlib::Absolutepath                $config,
  Optional[Stdlib::Absolutepath]      $config_dir,
  String                              $config_file_mode,
  Optional[String]                    $config_epp,
  Optional[String]                    $config_template,
  Boolean                             $disable_auth,
  Boolean                             $disable_dhclient,
  Boolean                             $disable_kernel,
  Boolean                             $disable_monitor,
  Boolean                             $enable_mode7,
  Optional[Array[String]]             $fudge,
  Stdlib::Absolutepath                $driftfile,
  Optional[Stdlib::Absolutepath]      $leapfile,
  Optional[Stdlib::Absolutepath]      $logfile,
  Optional[Variant[String, Integer]]  $logfile_group,
  String                              $logfile_mode,
  Optional[Variant[String, Integer]]  $logfile_user,
  Optional[String]                    $logconfig,
  Boolean                             $iburst_enable,
  Array[String]                       $keys,
  Boolean                             $keys_enable,
  Stdlib::Absolutepath                $keys_file,
  Optional[Ntp::Key_id]               $keys_controlkey,
  Optional[Ntp::Key_id]               $keys_requestkey,
  Optional[Array[Ntp::Key_id]]        $keys_trusted,
  Optional[Ntp::Poll_interval]        $minpoll,
  Optional[Ntp::Poll_interval]        $maxpoll,
  String                              $package_ensure,
  Boolean                             $package_manage,
  Array[String]                       $package_name,
  Optional[Integer[0]]                $panic,
  Array[String]                       $peers,
  Optional[Array[String]]             $pool,
  Array[String]                       $preferred_servers,
  Array[String]                       $noselect_servers,
  Array[String]                       $restrict,
  Array[String]                       $interfaces,
  Array[String]                       $interfaces_ignore,
  Array[String]                       $servers,
  Boolean                             $service_enable,
  Enum['running', 'stopped']          $service_ensure,
  Boolean                             $service_manage,
  String                              $service_name,
  Optional[String]                    $service_provider,
  Boolean                             $service_hasstatus,
  Boolean                             $service_hasrestart,
  Optional[Enum['yes','no']]          $slewalways,
  Optional[Array]                     $statistics,
  Optional[Stdlib::Absolutepath]      $statsdir,
  Optional[Integer[0, 65535]]         $stepout,
  Optional[Stdlib::Absolutepath]      $step_tickers_file,
  Optional[String]                    $step_tickers_epp,
  Optional[String]                    $step_tickers_template,
  Optional[Boolean]                   $tinker,
  Boolean                             $tos,
  Optional[Integer[1]]                $tos_maxclock,
  Optional[Integer[1]]                $tos_minclock,
  Optional[Integer[1]]                $tos_minsane,
  Optional[Integer[1]]                $tos_floor,
  Optional[Integer[1]]                $tos_ceiling,
  Optional[Integer[1]]                $tos_orphan,
  Variant[Boolean, Integer[0,1]]      $tos_cohort,
  Boolean                             $udlc,
  Optional[Integer[1,15]]             $udlc_stratum,
  Optional[Stdlib::Absolutepath]      $ntpsigndsocket,
  Optional[String]                    $authprov,
  Optional[String]                    $user,
  Optional[String]                    $daemon_extra_opts,
) {
  # defaults for tinker and panic are different, when running on virtual machines
  if $facts['is_virtual'] {
    $_tinker = pick($tinker, true)
    $_panic  = pick($panic, 0)
  } else {
    $_tinker = pick($tinker, false)
    $_panic  = $panic
  }

  contain ntp::install
  contain ntp::config
  contain ntp::service

  Class['ntp::install']
  -> Class['ntp::config']
  ~> Class['ntp::service']
}
