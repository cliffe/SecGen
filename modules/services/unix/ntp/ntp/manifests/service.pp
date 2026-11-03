# @summary
#   This class handles the ntp service.
#
# @api private
#
class ntp::service {
  if $ntp::service_manage == true {
    service { 'ntp':
      ensure     => $ntp::service_ensure,
      enable     => $ntp::service_enable,
      name       => $ntp::service_name,
      provider   => $ntp::service_provider,
      hasstatus  => $ntp::service_hasstatus,
      hasrestart => $ntp::service_hasrestart,
    }
  }
}
