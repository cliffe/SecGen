# == Class: docker
#
# Module to install an up-to-date version of Docker from package.
#
# === Parameters
#
# [*version*]
#   The package version to install, used to set the package name.
#   Defaults to undefined
#
# [*ensure*]
#   Passed to the docker package.
#   Defaults to present
#
# [*prerequired_packages*]
#   An array of additional packages that need to be installed to support
#   docker. Defaults change depending on the operating system.
#
# [*tcp_bind*]
#   The tcp socket to bind to in the format
#   tcp://127.0.0.1:4243
#   Defaults to undefined
#
# [*tls_enable*]
#   Enable TLS.
#   Defaults to false
#
# [*tls_verify*]
#  Use TLS and verify the remote
#  Defaults to true
#
# [*tls_cacert*]
#   Path to TLS CA certificate
#   Defaults to '/etc/docker/tls/ca.pem on linux and C:/ProgramData/docker/certs.d/ca.pem on Windows'
#
# [*tls_cert*]
#   Path to TLS certificate file
#   Defaults to '/etc/docker/tls/cert.pem on linux and C:/ProgramData/docker/certs.d/server-cert.pem on Windows'
#
# [*tls_key*]
#   Path to TLS key file
#   Defaults to '/etc/docker/tls/key.pem' on linux and C:/ProgramData/docker/certs.d/server-key.pem on Windows
#
# [*ip_forward*]
#   Enables IP forwarding on the Docker host.
#   The default is true.
#
# [*iptables*]
#   Enable Docker's addition of iptables rules.
#   Default is true.
#
# [*ip_masq*]
#   Enable IP masquerading for bridge's IP range.
#   The default is true.
#
# [*icc*]
#   Enable or disable Docker's unrestricted inter-container and Docker daemon host communication.
#   (Requires iptables=true to disable)
#   Default is undef. (Docker daemon's default is true)
#
# [*bip*]
#   Specify docker's network bridge IP, in CIDR notation.
#   Defaults to undefined.
#
# [*mtu*]
#   Docker network MTU.
#   Defaults to undefined.
#
# [*bridge*]
#   Attach containers to a pre-existing network bridge
#   use 'none' to disable container networking
#   Defaults to undefined.
#
# [*fixed_cidr*]
#   IPv4 subnet for fixed IPs
#   10.20.0.0/16
#   Defaults to undefined
#
# [*default_gateway*]
#   IPv4 address of the container default gateway;
#   this address must be part of the bridge subnet
#   (which is defined by bridge)
#   Defaults to undefined
#
# [*ipv6*]
#  Enables ipv6 support for the docker daemon
#  Defaults to false
#
# [*ipv6_cidr*]
#  IPv6 subnet for fixed IPs
#
# [*default_gateway_ipv6*]
#  IPv6 address of the container default gateway:
#  Defaults to undefined
#
# [*socket_bind*]
#   The unix socket to bind to. Defaults to
#   unix:///var/run/docker.sock.
#
# [*log_level*]
#   Set the logging level
#   Defaults to undef: docker defaults to info if no value specified
#   Valid values: debug, info, warn, error, fatal
#
# [*log_driver*]
#   Set the log driver.
#   Defaults to undef.
#   Docker default is json-file.
#   Valid values: none, json-file, syslog, journald, gelf, fluentd
#   Valid values description:
#     none     : Disables any logging for the container.
#                docker logs won't be available with this driver.
#     json-file: Default logging driver for Docker.
#                Writes JSON messages to file.
#     syslog   : Syslog logging driver for Docker.
#                Writes log messages to syslog.
#     journald : Journald logging driver for Docker.
#                Writes log messages to journald.
#     gelf     : Graylog Extended Log Format (GELF) logging driver for Docker.
#                Writes log messages to a GELF endpoint: Graylog or Logstash.
#     fluentd  : Fluentd logging driver for Docker.
#                Writes log messages to fluentd (forward input).
#     splunk   : Splunk logging driver for Docker.
#                Writes log messages to Splunk (HTTP Event Collector).
#
# [*log_opt*]
#   Set the log driver specific options
#   Defaults to undef
#   Valid values per log driver:
#     none     : undef
#     json-file:
#                max-size=[0-9+][k|m|g]
#                max-file=[0-9+]
#     syslog   :
#                syslog-address=[tcp|udp]://host:port
#                syslog-address=unix://path
#                syslog-facility=daemon|kern|user|mail|auth|
#                                syslog|lpr|news|uucp|cron|
#                                authpriv|ftp|
#                                local0|local1|local2|local3|
#                                local4|local5|local6|local7
#                syslog-tag="some_tag"
#     journald : undef
#     gelf     :
#                gelf-address=udp://host:port
#                gelf-tag="some_tag"
#     fluentd  :
#                fluentd-address=host:port
#                fluentd-tag={{.ID}} - short container id (12 characters)|
#                            {{.FullID}} - full container id
#                            {{.Name}} - container name
#     splunk   :
#                splunk-token=<splunk_http_event_collector_token>
#                splunk-url=https://your_splunk_instance:8088
#
# [*selinux_enabled*]
#   Enable selinux support. Default is false. SELinux does  not  presently
#   support  the  BTRFS storage driver.
#   Valid values: true, false
#
# [*use_upstream_package_source*]
#   Whether or not to use the upstream package source.
#   If you run your own package mirror, you may set this
#   to false.
#
# [*pin_upstream_package_source*]
#   Pin upstream package source; this option currently only has any effect on
#   apt-based distributions.  Set to false to remove pinning on the upstream
#   package repository.  See also "apt_source_pin_level".
#   Defaults to true
#
# [*apt_source_pin_level*]
#   What level to pin our source package repository to; this only is relevent
#   if you're on an apt-based system (Debian, Ubuntu, etc) and
#   $use_upstream_package_source is set to true.  Set this to false to disable
#   pinning, and undef to ensure the apt preferences file apt::source uses to
#   define pins is removed.
#   Defaults to 10
#
# [*package_source_location*]
#   If you're using an upstream package source, what is it's
#   location. Defaults to http://get.docker.com/ubuntu on Debian
#
# [*service_state*]
#   Whether you want to docker daemon to start up
#   Defaults to running
#
# [*service_enable*]
#   Whether you want to docker daemon to start up at boot
#   Defaults to true
#
# [*manage_service*]
#   Specify whether the service should be managed.
#   Valid values are 'true', 'false'.
#   Defaults to 'true'.
#
# [*root_dir*]
#   Custom root directory for containers
#   Defaults to undefined
#
# [*dns*]
#   Custom dns server address
#   Defaults to undefined
#
# [*dns_search*]
#   Custom dns search domains
#   Defaults to undefined
#
# [*socket_group*]
#   Group ownership of the unix control socket.
#   Defaults to undefined
#
# [*extra_parameters*]
#   Any extra parameters that should be passed to the docker daemon.
#   Defaults to undefined
#
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
# [*proxy*]
#   Will set the http_proxy and https_proxy env variables in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*no_proxy*]
#   Will set the no_proxy variable in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*storage_driver*]
#   Specify a storage driver to use
#   Default is undef: let docker choose the correct one
#   Valid values: aufs, devicemapper, btrfs, overlay, overlay2, vfs, zfs
#
# [*dm_basesize*]
#   The size to use when creating the base device, which limits the size of images and containers.
#   Default value is 10G
#
# [*dm_fs*]
#   The filesystem to use for the base image (xfs or ext4)
#   Defaults to ext4
#
# [*dm_mkfsarg*]
#   Specifies extra mkfs arguments to be used when creating the base device.
#
# [*dm_mountopt*]
#   Specifies extra mount options used when mounting the thin devices.
#
# [*dm_blocksize*]
#   A custom blocksize to use for the thin pool.
#   Default blocksize is 64K.
#   Warning: _DO NOT_ change this parameter after the lvm devices have been initialized.
#
# [*dm_loopdatasize*]
#   Specifies the size to use when creating the loopback file for the "data" device which is used for the thin pool
#   Default size is 100G
#
# [*dm_loopmetadatasize*]
#   Specifies the size to use when creating the loopback file for the "metadata" device which is used for the thin pool
#   Default size is 2G
#
# [*dm_datadev*]
#   (deprecated - dm_thinpooldev should be used going forward)
#   A custom blockdevice to use for data for the thin pool.
#
# [*dm_metadatadev*]
#   (deprecated - dm_thinpooldev should be used going forward)
#   A custom blockdevice to use for metadata for the thin pool.
#
# [*dm_thinpooldev*]
#   Specifies a custom block storage device to use for the thin pool.
#
# [*dm_use_deferred_removal*]
#   Enables use of deferred device removal if libdm and the kernel driver support the mechanism.
#
# [*dm_use_deferred_deletion*]
#    Enables use of deferred device deletion if libdm and the kernel driver support the mechanism.
#
# [*dm_blkdiscard*]
#   Enables or disables the use of blkdiscard when removing devicemapper devices.
#   Defaults to false
#
# [*dm_override_udev_sync_check*]
#   By default, the devicemapper backend attempts to synchronize with the udev
#   device manager for the Linux kernel. This option allows disabling that
#   synchronization, to continue even though the configuration may be buggy.
#   Defaults to true
#
# [*overlay2_override_kernel_check*]
#   Overrides the Linux kernel version check allowing using overlay2 with kernel < 4.0.
#   Default value is false
#
# [*manage_package*]
#   Won't install or define the docker package, useful if you want to use your own package
#   Defaults to true
#
# [*package_name*]
#   Specify custom package name
#   Default is set on a per system basis in docker::params
#
# [*service_name*]
#   Specify custom service name
#   Default is set on a per system basis in docker::params
#
# [*docker_command*]
#   Specify a custom docker command name
#   Default is set on a per system basis in docker::params
#
# [*daemon_subcommand*]
#  Specify a subcommand/flag for running docker as daemon
#  Default is set on a per system basis in docker::params
#
# [*docker_users*]
#   Specify an array of users to add to the docker group
#   Default is empty
#
# [*docker_group*]
#   Specify a string for the docker group
#   Default is OS and package specific
#
# [*daemon_environment_files*]
#   Specify additional environment files to add to the
#   service-overrides.conf
#
# [*repo_opt*]
#   Specify a string to pass as repository options (RedHat only)
#
# [*storage_devs*]
#   A quoted, space-separated list of devices to be used.
#
# [*storage_vg*]
#   The volume group to use for docker storage.
#
# [*storage_root_size*]
#   The size to which the root filesystem should be grown.
#
# [*storage_data_size*]
#   The desired size for the docker data LV
#
# [*storage_min_data_size*]
#   The minimum size of data volume otherwise pool creation fails
#
# [*storage_chunk_size*]
#   Controls the chunk size/block size of thin pool.
#
# [*storage_growpart*]
#   Enable resizing partition table backing root volume group.
#
# [*storage_auto_extend_pool*]
#   Enable/disable automatic pool extension using lvm
#
# [*storage_pool_autoextend_threshold*]
#   Auto pool extension threshold (in % of pool size)
#
# [*storage_pool_autoextend_percent*]
#   Extend the pool by specified percentage when threshold is hit.
#
# [*tmp_dir_config*]
#    Whether to set the TMPDIR value in the systemd config file
#    Default: true (set the value); false will comment out the line.
#    Note: false is backwards compatible prior to PR #58
#
# [*tmp_dir*]
#    Sets the tmp dir for Docker (path)
#
# [*registry_mirror*]
#   Sets the prefered container registry mirror.
#   Default: undef
#
# [*nuget_package_provider_version*]
#   The version of the NuGet Package provider
#   Default: undef
#
# [*docker_msft_provider_version*]
#   The version of the Microsoft Docker Provider Module
#   Default: undef

class docker(
  Optional[String] $version                                 = $docker::params::version,
  String $ensure                                            = $docker::params::ensure,
  Variant[Array[String], Hash] $prerequired_packages        = $docker::params::prerequired_packages,
  String $docker_ce_start_command                           = $docker::params::docker_ce_start_command,
  Optional[String] $docker_ce_package_name                  = $docker::params::docker_ce_package_name,
  Optional[String] $docker_ce_source_location               = $docker::params::package_ce_source_location,
  Optional[String] $docker_ce_key_source                    = $docker::params::package_ce_key_source,
  Optional[String] $docker_ce_key_id                        = $docker::params::package_ce_key_id,
  Optional[String] $docker_ce_release                       = $docker::params::package_ce_release,
  Optional[String] $docker_package_location                 = $docker::params::package_source_location,
  Optional[String] $docker_package_key_source               = $docker::params::package_key_source,
  Optional[Boolean] $docker_package_key_check_source        = $docker::params::package_key_check_source,
  Optional[String] $docker_package_key_id                   = $docker::params::package_key_id,
  Optional[String] $docker_package_release                  = $docker::params::package_release,
  String $docker_engine_start_command                       = $docker::params::docker_engine_start_command,
  String $docker_engine_package_name                        = $docker::params::docker_engine_package_name,
  String $docker_ce_channel                                 = $docker::params::docker_ce_channel,
  Optional[Boolean] $docker_ee                              = $docker::params::docker_ee,
  Optional[String] $docker_ee_package_name                  = $docker::params::package_ee_package_name,
  Optional[String] $docker_ee_source_location               = $docker::params::package_ee_source_location,
  Optional[String] $docker_ee_key_source                    = $docker::params::package_ee_key_source,
  Optional[String] $docker_ee_key_id                        = $docker::params::package_ee_key_id,
  Optional[String] $docker_ee_repos                         = $docker::params::package_ee_repos,
  Optional[String] $docker_ee_release                       = $docker::params::package_ee_release,
  Variant[String,Array[String],Undef] $tcp_bind             = $docker::params::tcp_bind,
  Boolean $tls_enable                                       = $docker::params::tls_enable,
  Boolean $tls_verify                                       = $docker::params::tls_verify,
  Optional[String] $tls_cacert                              = $docker::params::tls_cacert,
  Optional[String] $tls_cert                                = $docker::params::tls_cert,
  Optional[String] $tls_key                                 = $docker::params::tls_key,
  Boolean $ip_forward                                       = $docker::params::ip_forward,
  Boolean $ip_masq                                          = $docker::params::ip_masq,
  Optional[Boolean]$ipv6                                    = $docker::params::ipv6,
  Optional[String]$ipv6_cidr                                = $docker::params::ipv6_cidr,
  Optional[String]$default_gateway_ipv6                     = $docker::params::default_gateway_ipv6,
  Optional[String] $bip                                     = $docker::params::bip,
  Optional[String] $mtu                                     = $docker::params::mtu,
  Boolean $iptables                                         = $docker::params::iptables,
  Optional[Boolean] $icc                                    = $docker::params::icc,
  String $socket_bind                                       = $docker::params::socket_bind,
  Optional[String] $fixed_cidr                              = $docker::params::fixed_cidr,
  Optional[String] $bridge                                  = $docker::params::bridge,
  Optional[String] $default_gateway                         = $docker::params::default_gateway,
  Optional[String] $log_level                               = $docker::params::log_level,
  Optional[String] $log_driver                              = $docker::params::log_driver,
  Array $log_opt                                            = $docker::params::log_opt,
  Optional[Boolean] $selinux_enabled                        = $docker::params::selinux_enabled,
  Optional[Boolean] $use_upstream_package_source            = $docker::params::use_upstream_package_source,
  Optional[Boolean] $pin_upstream_package_source            = $docker::params::pin_upstream_package_source,
  Optional[Integer] $apt_source_pin_level                   = $docker::params::apt_source_pin_level,
  Optional[String] $package_release                         = $docker::params::package_release,
  String $service_state                                     = $docker::params::service_state,
  Boolean $service_enable                                   = $docker::params::service_enable,
  Boolean $manage_service                                   = $docker::params::manage_service,
  Optional[String] $root_dir                                = $docker::params::root_dir,
  Optional[Boolean] $tmp_dir_config                         = $docker::params::tmp_dir_config,
  Optional[String] $tmp_dir                                 = $docker::params::tmp_dir,
  Variant[String,Array,Undef] $dns                          = $docker::params::dns,
  Variant[String,Array,Undef] $dns_search                   = $docker::params::dns_search,
  Optional[String] $socket_group                            = $docker::params::socket_group,
  Array $labels                                             = $docker::params::labels,
  Variant[String,Array,Undef] $extra_parameters             = undef,
  Variant[String,Array,Undef] $shell_values                 = undef,
  Optional[String] $proxy                                   = $docker::params::proxy,
  Optional[String] $no_proxy                                = $docker::params::no_proxy,
  Optional[String] $storage_driver                          = $docker::params::storage_driver,
  Optional[String] $dm_basesize                             = $docker::params::dm_basesize,
  Optional[String] $dm_fs                                   = $docker::params::dm_fs,
  Optional[String] $dm_mkfsarg                              = $docker::params::dm_mkfsarg,
  Optional[String] $dm_mountopt                             = $docker::params::dm_mountopt,
  Optional[String] $dm_blocksize                            = $docker::params::dm_blocksize,
  Optional[String] $dm_loopdatasize                         = $docker::params::dm_loopdatasize,
  Optional[String] $dm_loopmetadatasize                     = $docker::params::dm_loopmetadatasize,
  Optional[String] $dm_datadev                              = $docker::params::dm_datadev,
  Optional[String] $dm_metadatadev                          = $docker::params::dm_metadatadev,
  Optional[String] $dm_thinpooldev                          = $docker::params::dm_thinpooldev,
  Optional[Boolean] $dm_use_deferred_removal                = $docker::params::dm_use_deferred_removal,
  Optional[Boolean] $dm_use_deferred_deletion               = $docker::params::dm_use_deferred_deletion,
  Optional[Boolean] $dm_blkdiscard                          = $docker::params::dm_blkdiscard,
  Optional[Boolean] $dm_override_udev_sync_check            = $docker::params::dm_override_udev_sync_check,
  Boolean $overlay2_override_kernel_check                   = $docker::params::overlay2_override_kernel_check,
  Optional[String] $execdriver                              = $docker::params::execdriver,
  Boolean $manage_package                                   = $docker::params::manage_package,
  Optional[String] $package_source                          = $docker::params::package_source,
  Optional[String] $service_name                            = $docker::params::service_name,
  Array $docker_users                                       = [],
  String $docker_group                                      = $docker::params::docker_group,
  Array $daemon_environment_files                           = [],
  Variant[String,Hash,Undef] $repo_opt                      = $docker::params::repo_opt,
  Optional[String] $os_lc                                   = $docker::params::os_lc,
  Optional[String] $storage_devs                            = $docker::params::storage_devs,
  Optional[String] $storage_vg                              = $docker::params::storage_vg,
  Optional[String] $storage_root_size                       = $docker::params::storage_root_size,
  Optional[String] $storage_data_size                       = $docker::params::storage_data_size,
  Optional[String] $storage_min_data_size                   = $docker::params::storage_min_data_size,
  Optional[String] $storage_chunk_size                      = $docker::params::storage_chunk_size,
  Optional[Boolean] $storage_growpart                      = $docker::params::storage_growpart,
  Optional[String] $storage_auto_extend_pool                = $docker::params::storage_auto_extend_pool,
  Optional[String] $storage_pool_autoextend_threshold       = $docker::params::storage_pool_autoextend_threshold,
  Optional[String] $storage_pool_autoextend_percent         = $docker::params::storage_pool_autoextend_percent,
  Variant[String,Boolean,Undef] $storage_config             = $docker::params::storage_config,
  Optional[String] $storage_config_template                 = $docker::params::storage_config_template,
  Optional[String] $storage_setup_file                      = $docker::params::storage_setup_file,
  Optional[String] $service_provider                        = $docker::params::service_provider,
  Variant[String,Boolean,Undef] $service_config             = $docker::params::service_config,
  Optional[String] $service_config_template                 = $docker::params::service_config_template,
  Variant[String,Boolean,Undef] $service_overrides_template = $docker::params::service_overrides_template,
  Optional[Boolean] $service_hasstatus                      = $docker::params::service_hasstatus,
  Optional[Boolean] $service_hasrestart                     = $docker::params::service_hasrestart,
  Optional[String] $registry_mirror                         = $docker::params::registry_mirror,
  # Windows specific parameters
  Optional[String] $docker_msft_provider_version            = $docker::params::docker_msft_provider_version,
  Optional[String] $nuget_package_provider_version          = $docker::params::nuget_package_provider_version,
) inherits docker::params {


  if $::osfamily {
    assert_type(Pattern[/^(Debian|RedHat|windows)$/], $::osfamily) |$a, $b| {
      fail(translate('This module only works on Debian, Red Hat or Windows based systems.'))
    }
  }

  if ($::operatingsystem == 'CentOS') and (versioncmp($::operatingsystemmajrelease, '7') < 0) {
    fail(translate('This module only works on CentOS version 7 and higher based systems.'))
  }

  if ($default_gateway) and (!$bridge) {
    fail(translate('You must provide the $bridge parameter.'))
  }

  if $log_level {
    assert_type(Pattern[/^(debug|info|warn|error|fatal)$/], $log_level) |$a, $b| {
        fail(translate('log_level must be one of debug, info, warn, error or fatal'))
    }
  }

  if $log_driver {
    if $::osfamily == 'windows' {
      assert_type(Pattern[/^(none|json-file|syslog|gelf|fluentd|splunk|etwlogs)$/], $log_driver) |$a, $b| {
        fail(translate('log_driver must be one of none, json-file, syslog, gelf, fluentd, splunk or etwlogs'))
      }
    } else {
      assert_type(Pattern[/^(none|json-file|syslog|journald|gelf|fluentd|splunk)$/], $log_driver) |$a, $b| {
        fail(translate('log_driver must be one of none, json-file, syslog, journald, gelf, fluentd or splunk'))
      }
    }
  }

  if $storage_driver {
    if $::osfamily == 'windows' {
      assert_type(Pattern[/^(windowsfilter)$/], $storage_driver) |$a, $b| {
          fail(translate('Valid values for storage_driver on windows are windowsfilter'))
      }
    } else {
      assert_type(Pattern[/^(aufs|devicemapper|btrfs|overlay|overlay2|vfs|zfs)$/], $storage_driver) |$a, $b| {
        fail(translate('Valid values for storage_driver are aufs, devicemapper, btrfs, overlay, overlay2, vfs, zfs.'))
      }
    }
  }

  if ($bridge) and ($::osfamily == 'windows') {
      assert_type(Pattern[/^(none|nat|transparent|overlay|l2bridge|l2tunnel)$/], $bridge) |$a, $b| {
        fail(translate('bridge must be one of none, nat, transparent, overlay, l2bridge or l2tunnel on Windows.'))
    }
  }

  if $dm_fs {
    assert_type(Pattern[/^(ext4|xfs)$/], $dm_fs) |$a, $b| {
      fail(translate('Only ext4 and xfs are supported currently for dm_fs.'))
    }
  }

  if ($dm_loopdatasize or $dm_loopmetadatasize) and ($dm_datadev or $dm_metadatadev) {
    fail(translate('You should provide parameters only for loop lvm or direct lvm, not both.'))
  }

# lint:ignore:140chars
  if ($dm_datadev or $dm_metadatadev) and $dm_thinpooldev {
    fail(translate('You can use the $dm_thinpooldev parameter, or the $dm_datadev and $dm_metadatadev parameter pair, but you cannot use both.'))
  }
# lint:endignore

  if ($dm_datadev or $dm_metadatadev) {
    notice('The $dm_datadev and $dm_metadatadev parameter pair are deprecated.  The $dm_thinpooldev parameter should be used instead.')
  }

  if ($dm_datadev and !$dm_metadatadev) or (!$dm_datadev and $dm_metadatadev) {
    fail(translate('You need to provide both $dm_datadev and $dm_metadatadev parameters for direct lvm.'))
  }

  if ($dm_basesize or $dm_fs or $dm_mkfsarg or $dm_mountopt or $dm_blocksize or $dm_loopdatasize or
      $dm_loopmetadatasize or $dm_datadev or $dm_metadatadev) and ($storage_driver != 'devicemapper') {
    fail(translate('Values for dm_ variables will be ignored unless storage_driver is set to devicemapper.'))
  }

  if($tls_enable) {
    if(!$tcp_bind) {
        fail(translate('You need to provide tcp bind parameter for TLS.'))
    }
  }

if ( $version == undef ) or ( $version !~ /^(17[.]0[0-5][.][0-1](~|-|\.)ce|1.\d+)/ ) {
  if ( $docker_ee) {
      $package_location = $docker::docker_ee_source_location
      $package_key_source = $docker::docker_ee_key_source
      $package_key_check_source = true
      $package_key = $docker::docker_ee_key_id
      $package_repos = $docker::docker_ee_repos
      $release = $docker::docker_ee_release
      $docker_start_command = $docker::docker_ee_start_command
      $docker_package_name = $docker::docker_ee_package_name
    } else {
        case $::osfamily {
          'Debian' : {
            $package_location = $docker_ce_source_location
            $package_key_source = $docker_ce_key_source
            $package_key = $docker_ce_key_id
            $package_repos = $docker_ce_channel
            $release = $docker_ce_release
            }
          'Redhat' : {
            $package_location = "https://download.docker.com/linux/centos/${::operatingsystemmajrelease}/${::architecture}/${docker_ce_channel}"
            $package_key_source = $docker_ce_key_source
            $package_key_check_source = true
            }
          'windows': {
            fail(translate('This module only work for Docker Enterprise Edition on Windows.'))
          }
          default: {}
        }
        $docker_start_command = $docker_ce_start_command
        $docker_package_name = $docker_ce_package_name
    }
  } else {
    case $::osfamily {
      'Debian' : {
        $package_location = $docker_package_location
        $package_key_source = $docker_package_key_source
        $package_key_check_source = $docker_package_key_check_source
        $package_key = $docker_package_key_id
        $package_repos = 'main'
        $release = $docker_package_release
        }
      'Redhat' : {
        $package_location = $docker_package_location
        $package_key_source = $docker_package_key_source
        $package_key_check_source = $docker_package_key_check_source
      }
      default : {}
    }
    $docker_start_command = $docker_engine_start_command
    $docker_package_name = $docker_engine_package_name
  }

  if ( $version != undef ) and ( $version =~ /^(17[.]0[0-4]|1.\d+)/ ) {
    $root_dir_flag = '-g'
  } else {
    $root_dir_flag = '--data-root'
  }

  if $ensure != 'absent' {
    contain 'docker::repos'
    contain 'docker::install'
    contain 'docker::config'
    contain 'docker::service'

    Class['docker::repos'] -> Class['docker::install'] -> Class['docker::config'] -> Class['docker::service']
    Class['docker'] -> Docker::Registry <||> -> Docker::Image <||>
    Class['docker'] -> Docker::Image <||>
    Class['docker'] -> Docker::Run <||>
  } else {
    contain 'docker::repos'
    contain 'docker::install'

    Class['docker::repos'] -> Class['docker::install']
  }
}
