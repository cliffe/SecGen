# auditbeat::config
# @api private
#
# @summary It configures the auditbeat shipper
class auditbeat::config {
  $auditbeat_bin = '/usr/share/auditbeat/bin/auditbeat'

  $validate_cmd = $auditbeat::disable_configtest ? {
    true => undef,
    default => "${auditbeat_bin} test config -c %",
  }

  $auditbeat_config = delete_undef_values({
    'name'                      => $auditbeat::beat_name ,
    'fields_under_root'         => $auditbeat::fields_under_root,
    'fields'                    => $auditbeat::fields,
    'xpack'                     => $auditbeat::xpack,
    'tags'                      => $auditbeat::tags,
    'queue'                     => $auditbeat::queue,
    'logging'                   => $auditbeat::logging,
    'output'                    => $auditbeat::outputs,
    'processors'                => $auditbeat::processors,
    'auditbeat'                 => {
      'modules'                 => $auditbeat::modules,
    },
  })

  file { '/etc/auditbeat/auditbeat.yml':
    ensure       => $auditbeat::ensure,
    owner        => 'root',
    group        => 'root',
    mode         => $auditbeat::config_file_mode,
    content      => inline_template('<%= @auditbeat_config.to_yaml()  %>'),
    validate_cmd => $validate_cmd,
  }
}
