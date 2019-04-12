# Class: cron::service
#
# This class managed the cron service
#
# This class should not be used directly under normal circumstances
# Instead, use the *cron* class.
#
class cron::service {
  if $::cron::manage_service {
    service { $::cron::service_name:
      ensure => $::cron::service_ensure,
      enable => $::cron::service_enable,
    }
  }
}
