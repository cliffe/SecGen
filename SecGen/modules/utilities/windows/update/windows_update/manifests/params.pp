# Author::    Liam Bennett (mailto:liamjbennett@gmail.com)
# Copyright:: Copyright (c) 2014 Liam Bennett
# License::   MIT

# == Class windows_autoupdate::params
#
# This private class is meant to be called from `windows_autoupdate`
# It sets variables according to platform
#
class windows_autoupdate::params {

  $noAutoUpdate = undef
  $aUOptions = undef
  $scheduledInstallDay = undef
  $scheduledInstallTime = undef
  $useWUServer = undef
  $rescheduleWaitTime = undef
  $noAutoRebootWithLoggedOnUsers = undef

  $au_options                          = '4'
  $no_auto_reboot_with_logged_on_users = '0'
  $no_auto_update                      = '0'
  $reschedule_wait_time                = '10'
  $scheduled_install_day               = '1'
  $scheduled_install_time              = '10'
  $use_wuserver                        = '0'

  if $::operatingsystemrelease == 'Server 2012' {
    $p_reg_key = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'
  } else {
    $p_reg_key = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
  }

}
