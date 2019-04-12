# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*ip_forward*]
#   This flag interacts with the IP forwarding setting on
#   your host system's kernel
#
# [*iptables*]
#   Enable Docker's addition of iptables rules
#
# [*ip_masq*]
#   Enable IP masquerading for bridge's IP range.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*socket_group*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
# [*manage_service*]
#   Specify whether the service should be managed.
#   Valid values are 'true', 'false'.
#   Defaults to 'true'.
#
class docker::service (
  $docker_command                    = $docker::docker_command,
  $docker_start_command              = $docker::docker_start_command,
  $service_name                      = $docker::service_name,
  $tcp_bind                          = $docker::tcp_bind,
  $ip_forward                        = $docker::ip_forward,
  $iptables                          = $docker::iptables,
  $ip_masq                           = $docker::ip_masq,
  $icc                               = $docker::icc,
  $bridge                            = $docker::bridge,
  $fixed_cidr                        = $docker::fixed_cidr,
  $default_gateway                   = $docker::default_gateway,
  $ipv6                              = $docker::ipv6,
  $ipv6_cidr                         = $docker::ipv6_cidr,
  $default_gateway_ipv6              = $docker::default_gateway_ipv6,
  $socket_bind                       = $docker::socket_bind,
  $log_level                         = $docker::log_level,
  $log_driver                        = $docker::log_driver,
  $log_opt                           = $docker::log_opt,
  $selinux_enabled                   = $docker::selinux_enabled,
  $socket_group                      = $docker::socket_group,
  $labels                            = $docker::labels,
  $dns                               = $docker::dns,
  $dns_search                        = $docker::dns_search,
  $service_state                     = $docker::service_state,
  $service_enable                    = $docker::service_enable,
  $manage_service                    = $docker::manage_service,
  $root_dir                          = $docker::root_dir,
  $extra_parameters                  = $docker::extra_parameters,
  $shell_values                      = $docker::shell_values,
  $proxy                             = $docker::proxy,
  $no_proxy                          = $docker::no_proxy,
  $execdriver                        = $docker::execdriver,
  $bip                               = $docker::bip,
  $mtu                               = $docker::mtu,
  $storage_driver                    = $docker::storage_driver,
  $dm_basesize                       = $docker::dm_basesize,
  $dm_fs                             = $docker::dm_fs,
  $dm_mkfsarg                        = $docker::dm_mkfsarg,
  $dm_mountopt                       = $docker::dm_mountopt,
  $dm_blocksize                      = $docker::dm_blocksize,
  $dm_loopdatasize                   = $docker::dm_loopdatasize,
  $dm_loopmetadatasize               = $docker::dm_loopmetadatasize,
  $dm_datadev                        = $docker::dm_datadev,
  $dm_metadatadev                    = $docker::dm_metadatadev,
  $tmp_dir_config                    = $docker::tmp_dir_config,
  $tmp_dir                           = $docker::tmp_dir,
  $dm_thinpooldev                    = $docker::dm_thinpooldev,
  $dm_use_deferred_removal           = $docker::dm_use_deferred_removal,
  $dm_use_deferred_deletion          = $docker::dm_use_deferred_deletion,
  $dm_blkdiscard                     = $docker::dm_blkdiscard,
  $dm_override_udev_sync_check       = $docker::dm_override_udev_sync_check,
  $overlay2_override_kernel_check    = $docker::overlay2_override_kernel_check,
  $storage_devs                      = $docker::storage_devs,
  $storage_vg                        = $docker::storage_vg,
  $storage_root_size                 = $docker::storage_root_size,
  $storage_data_size                 = $docker::storage_data_size,
  $storage_min_data_size             = $docker::storage_min_data_size,
  $storage_chunk_size                = $docker::storage_chunk_size,
  $storage_growpart                  = $docker::storage_growpart,
  $storage_auto_extend_pool          = $docker::storage_auto_extend_pool,
  $storage_pool_autoextend_threshold = $docker::storage_pool_autoextend_threshold,
  $storage_pool_autoextend_percent   = $docker::storage_pool_autoextend_percent,
  $storage_config                    = $docker::storage_config,
  $storage_config_template           = $docker::storage_config_template,
  $storage_setup_file                = $docker::storage_setup_file,
  $service_provider                  = $docker::service_provider,
  $service_config                    = $docker::service_config,
  $service_config_template           = $docker::service_config_template,
  $service_overrides_template        = $docker::service_overrides_template,
  $service_hasstatus                 = $docker::service_hasstatus,
  $service_hasrestart                = $docker::service_hasrestart,
  $daemon_environment_files          = $docker::daemon_environment_files,
  $tls_enable                        = $docker::tls_enable,
  $tls_verify                        = $docker::tls_verify,
  $tls_cacert                        = $docker::tls_cacert,
  $tls_cert                          = $docker::tls_cert,
  $tls_key                           = $docker::tls_key,
  $registry_mirror                   = $docker::registry_mirror,
  $root_dir_flag                     = $docker::root_dir_flag,
) {

  unless $::osfamily =~ /(Debian|RedHat|windows)/ {
    fail(translate('The docker::service class needs a Debian, Redhat or Windows based system.'))
  }

  $dns_array = any2array($dns)
  $dns_search_array = any2array($dns_search)
  $labels_array = any2array($labels)
  $extra_parameters_array = any2array($extra_parameters)
  $shell_values_array = any2array($shell_values)
  $tcp_bind_array = any2array($tcp_bind)

  if $service_config != undef {
    $_service_config = $service_config
  } else {
    if $::osfamily == 'Debian' {
      $_service_config = "/etc/default/${service_name}"
    }
  }

  $_manage_service = $manage_service ? {
    true    => Service['docker'],
    default => [],
  }

  if $::osfamily == 'RedHat' {
    file { $storage_setup_file:
      ensure  => present,
      force   => true,
      content => template('docker/etc/sysconfig/docker-storage-setup.erb'),
      before  => $_manage_service,
      notify  => $_manage_service,
    }
  }
  if $::osfamily == 'windows' {
    file { ['C:/ProgramData/docker/', 'C:/ProgramData/docker/config/']:
      ensure  => directory,
    }
  }

  case $service_provider {
    'systemd': {
      file { '/etc/systemd/system/docker.service.d':
        ensure => directory,
      }

      if $service_overrides_template {
        file { '/etc/systemd/system/docker.service.d/service-overrides.conf':
          ensure  => present,
          content => template($service_overrides_template),
          notify  => Exec['docker-systemd-reload-before-service'],
          before  => $_manage_service,
        }
        exec { 'docker-systemd-reload-before-service':
          path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
          command     => 'systemctl daemon-reload > /dev/null',
          before      => $_manage_service,
          refreshonly => true,
        }
      }
    }
    'upstart': {
      file { '/etc/init.d/docker':
        ensure => 'link',
        target => '/lib/init/upstart-job',
        force  => true,
        notify => $_manage_service,
      }
    }
    default: {}
  }

  if $storage_config {
    file { $storage_config:
      ensure  => present,
      force   => true,
      content => template($storage_config_template),
      notify  => $_manage_service,
    }
  }

  if $_service_config {
    file { $_service_config:
      ensure  => present,
      force   => true,
      content => template($service_config_template),
      notify  => $_manage_service,
    }
  }

  if $manage_service {
    if $::osfamily == 'windows' {
      reboot { 'pending_reboot':
        when    => 'pending',
        onlyif  => 'component_based_servicing',
        timeout => 1,
      }
    }

    if ! defined(Service['docker']) {
      service { 'docker':
        ensure     => $service_state,
        name       => $service_name,
        enable     => $service_enable,
        hasstatus  => $service_hasstatus,
        hasrestart => $service_hasrestart,
        provider   => $service_provider,
      }
    }
  }
}
