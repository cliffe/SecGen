# Author::    Liam Bennett (mailto:liamjbennett@gmail.com)
# Copyright:: Copyright (c) 2014 Liam Bennett
# License::   MIT

# == Class: windows_autoupdate
#
# Module to mananage the configuration of a machines autoupdate settings
#
# === Requirements/Dependencies
#
# Currently reequires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*no_auto_update*]
# Ensuring the state of automatic updates.
# 0: Automatic Updates is enabled (default)
# 1: Automatic Updates is disabled.
#
# [*au_options*]
# The option to configure what to do when an update is avaliable
# 1: Keep my computer up to date has been disabled in Automatic Updates.
# 2: Notify of download and installation.
# 3: Automatically download and notify of installation.
# 4: Automatically download and scheduled installation.
#
# [*scheduled_install_day*]
# The day of the week to install updates.
# 0: Every day.
# 1 through 7: The days of the week from Sunday (1) to Saturday (7).
#
# [*scheduled_install_time*]
# The time of day (in 24hr format) when to install updates.
#
# [*use_wuserver*]
# If set to 1, windows autoupdates will use a local WSUS server rather than windows update.
#
# [*reschedule_wait_time*]
# The time period to wait between the time Automatic Updates starts and the time it begins installations
# where the scheduled times have passed. The time is set in minutes from 1 to 60
#
# [*no_auto_reboot_with_logged_on_users*]
# If set to 1, Automatic Updates does not automatically restart a computer while users are logged on.
#
# === Examples
#
# Manage autoupdates with windows default settings:
#
#   include windows_autoupdate
#
# Disable auto updates (don't do this!):
#
#   class { 'windows_autoupdate': no_auto_update => '1' }
#
class windows_autoupdate(
  $noAutoUpdate                  = $windows_autoupdate::params::noAutoUpdate,
  $aUOptions                     = $windows_autoupdate::params::aUOptions,
  $scheduledInstallDay           = $windows_autoupdate::params::scheduledInstallDay,
  $scheduledInstallTime          = $windows_autoupdate::params::scheduledInstallTime,
  $useWUServer                   = $windows_autoupdate::params::useWUServer,
  $rescheduleWaitTime            = $windows_autoupdate::params::rescheduleWaitTime,
  $noAutoRebootWithLoggedOnUsers = $windows_autoupdate::params::noAutoRebootWithLoggedOnUsers,

  $au_options                          = $windows_autoupdate::params::au_options,
  $no_auto_reboot_with_logged_on_users = $windows_autoupdate::params::no_auto_reboot_with_logged_on_users,
  $no_auto_update                      = $windows_autoupdate::params::no_auto_update,
  $reschedule_wait_time                = $windows_autoupdate::params::reschedule_wait_time,
  $scheduled_install_day               = $windows_autoupdate::params::scheduled_install_day,
  $scheduled_install_time              = $windows_autoupdate::params::scheduled_install_time,
  $use_wuserver                        = $windows_autoupdate::params::use_wuserver,
) inherits windows_autoupdate::params {

  if $aUOptions {
    warning("${module_name}: The use of aUOptions is deprecated. Use au_options instead.")
    $real_au_options = $aUOptions
  } else {
    $real_au_options = $au_options
  }

  if $noAutoRebootWithLoggedOnUsers {
    warning("${module_name}: The use of noAutoRebootWithLoggedOnUsers is deprecated. Use no_auto_reboot_with_logged_on_users instead.")
    $real_no_auto_reboot_with_logged_on_users = $noAutoRebootWithLoggedOnUsers
  } else {
    $real_no_auto_reboot_with_logged_on_users = $no_auto_reboot_with_logged_on_users
  }

  if $noAutoUpdate {
    warning("${module_name}: The use of noAutoUpdate is deprecated. Use no_auto_update instead.")
    $real_no_auto_update = $noAutoUpdate
  } else {
    $real_no_auto_update = $no_auto_update
  }

  if $rescheduleWaitTime {
    warning("${module_name}: The use of rescheduleWaitTime is deprecated. Use reschedule_wait_time instead.")
    $real_reschedule_wait_time = $rescheduleWaitTime
  } else {
    $real_reschedule_wait_time = $reschedule_wait_time
  }

  if $scheduledInstallDay {
    warning("${module_name}: The use of scheduledInstallDay is deprecated. Use scheduled_install_day instead.")
    $real_scheduled_install_day = $scheduledInstallDay
  } else {
    $real_scheduled_install_day = $scheduled_install_day
  }

  if $scheduledInstallTime {
    warning("${module_name}: The use of cheduledInstallTime is deprecated. Use scheduled_install_time instead.")
    $real_scheduled_install_time = $scheduledInstallTime
  } else {
    $real_scheduled_install_time = $scheduled_install_time
  }

  if $useWUServer {
    warning("${module_name}: The use of useWUServer is deprecated. Use use_wuserver instead.")
    $real_use_wuserver = $useWUServer
  } else {
    $real_use_wuserver = $use_wuserver
  }

  validate_re($real_no_auto_update,['^[0,1]$'])
  validate_re($real_au_options,['^[1-4]$'])
  validate_re($real_scheduled_install_day,['^[0-7]$'])
  validate_re($real_scheduled_install_time,['^(2[0-3]|1?[0-9])$'])
  validate_re($real_use_wuserver,['^[0,1]$'])
  validate_re($real_reschedule_wait_time,['^(60|[1-5][0-9]|[1-9])$'])
  validate_re($real_no_auto_reboot_with_logged_on_users,['^[0,1]$'])

  service { 'wuauserv':
    ensure    => 'running',
    enable    => true,
    subscribe => Registry_value['NoAutoUpdate','AUOptions','ScheduledInstallDay', 'ScheduledInstallTime','UseWUServer','RescheduleWaitTime','NoAutoRebootWithLoggedOnUsers']
  }

  registry_key { $windows_autoupdate::params::p_reg_key:
    ensure => present
  }

  registry_value { 'NoAutoUpdate':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\NoAutoUpdate",
    type   => 'dword',
    data   => $real_no_auto_update
  }

  registry_value { 'AUOptions':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\AUOptions",
    type   => 'dword',
    data   => $real_au_options
  }

  registry_value { 'ScheduledInstallDay':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\ScheduledInstallDay",
    type   => 'dword',
    data   => $real_scheduled_install_day
  }

  registry_value { 'ScheduledInstallTime':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\ScheduledInstallTime",
    type   => 'dword',
    data   => $real_scheduled_install_time
  }

  registry_value { 'UseWUServer':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\UseWUServer",
    type   => 'dword',
    data   => $real_use_wuserver
  }

  registry_value { 'RescheduleWaitTime':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\RescheduleWaitTime",
    type   => 'dword',
    data   => $real_reschedule_wait_time
  }

  registry_value { 'NoAutoRebootWithLoggedOnUsers':
    ensure => present,
    path   => "${windows_autoupdate::params::p_reg_key}\\NoAutoRebootWithLoggedOnUsers",
    type   => 'dword',
    data   => $real_no_auto_reboot_with_logged_on_users
  }
}
