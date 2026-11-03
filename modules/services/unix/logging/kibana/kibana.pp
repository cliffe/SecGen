unless defined('analysis_alert_action_server') {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $kibana_ip = $secgen_parameters['kibana_ip'][0]
  $elasticsearch_ip = $secgen_parameters['elasticsearch_ip'][0]
  $elasticsearch_port = 0 + $secgen_parameters['elasticsearch_port'][0]
  $kibana_port = 0 + $secgen_parameters['kibana_port'][0]

  class { 'kibana':
    elasticsearch_ip => $elasticsearch_ip,
    kibana_ip => $kibana_ip,
    elasticsearch_port => $elasticsearch_port,
    kibana_port => $kibana_port
  }
}