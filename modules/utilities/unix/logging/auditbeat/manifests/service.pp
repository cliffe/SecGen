# auditbeat::service
# @api private
#
# @summary It manages the auditbeat service
class auditbeat::service {
  if $auditbeat::ensure == 'present' {
    case $auditbeat::service_ensure {
      'enabled': {
        $service_status = 'running'
        $service_enabled = true
      }
      'disabled': {
        $service_status = 'stopped'
        $service_enabled = false
      }
      'running': {
        $service_status = 'running'
        $service_enabled = false
      }
      'unmanaged': {
        $service_status = undef
        $service_enabled = false
      }
      default: {}
    }
  }
  else {
    $service_status = 'stopped'
    $service_enabled = false
  }

  service {'auditbeat':
    ensure   => $service_status,
    enable   => $service_enabled,
    provider => $auditbeat::service_provider,
  }
}
