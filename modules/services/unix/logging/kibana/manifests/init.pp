class kibana($elasticsearch_ip, $kibana_ip = 'localhost', $elasticsearch_port = '9200', $kibana_port = '5601') {

  class { 'kibana::install': }->
  class { 'kibana::config':
    elasticsearch_ip => $elasticsearch_ip,
    kibana_ip => $kibana_ip,
    elasticsearch_port => $elasticsearch_port,
    kibana_port => $kibana_port
  } ->
  class { 'kibana::service':
    kibana_ip => $kibana_ip,
    kibana_port => $kibana_port
  }

}