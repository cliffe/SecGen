unless defined('analysis_alert_action_client') {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $logstash_ip = $secgen_parameters['logstash_ip'][0]
  $logstash_port = 0 + $secgen_parameters['logstash_port'][0]

  class { 'auditbeat':
    modules => [
      {
        'module'  => 'auditd',
        'enabled' => true,
        'audit_rule_files' => ['${path.config}/audit.rules.d/*.conf'],
      },
    ],
    outputs => {
      'logstash' => {
        'hosts' => ["$logstash_ip:$logstash_port"],
      },
    },
  }
}