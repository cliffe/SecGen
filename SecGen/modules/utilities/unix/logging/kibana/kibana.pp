$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

$kibana_ip = $secgen_parameters['kibana_ip'][0]
$kibana_port = 0 + $secgen_parameters['kibana_port'][0]

$elasticsearch_ip = $secgen_parameters['elasticsearch_ip'][0]  # TODO: Which IP address? how do we do this with two servers?
$elasticsearch_port = 0 + $secgen_parameters['elasticsearch_port'][0]  # TODO: Which IP address? how do we do this with two servers?

class { 'kibana':
  config => {
    'server.host'       => $kibana_ip,
    'elasticsearch.url' => "http://$elasticsearch_ip:$elasticsearch_port",
    'server.port'       => $kibana_port,
  }
}