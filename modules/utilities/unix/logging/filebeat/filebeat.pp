unless defined('analysis_alert_action_client') {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $logstash_ip = $secgen_parameters['logstash_ip'][0]
  $logstash_port = 0 + $secgen_parameters['logstash_port'][0]

  class { 'filebeat':
    major_version => '7',
    outputs       => {
      'logstash' => {
        'hosts' => [
          "$logstash_ip:$logstash_port",
        ],
        'index' => 'filebeat',
      },
    },
  }

  # Filebeat 7 loads conf.d/*.yml as a list of inputs; the legacy
  # filebeat::prospector template writes a 'filebeat: prospectors:' map that
  # 7.x cannot load. The old doc_type label is kept as a tag.
  filebeat::input { 'syslogs':
    paths => [
      '/var/log/auth.log',
      '/var/log/syslog',
    ],
    tags  => ['syslog-beat'],
  }
}