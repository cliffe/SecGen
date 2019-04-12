$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
$logstash_ip = $secgen_parameters['logstash_ip'][0]
$logstash_port = 0 + $secgen_parameters['logstash_port'][0]

class { 'filebeat':
  outputs => {
    'logstash' => {
      'hosts' => [
        "$logstash_ip:$logstash_port",
      ],
      'index' => 'filebeat',
    },
  },
}

filebeat::prospector { 'syslogs':
  paths    => [
    '/var/log/auth.log',
    '/var/log/syslog',
  ],
  doc_type => 'syslog-beat',
}