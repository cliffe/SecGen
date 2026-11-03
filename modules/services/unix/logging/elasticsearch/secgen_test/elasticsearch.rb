require_relative '../../../../../lib/post_provision_test'

class ElasticsearchTest < PostProvisionTest
  def initialize
    self.module_name = 'elasticsearch'
    self.module_path = get_module_path(__FILE__)
    super
    # the port comes only from the elasticsearch_port input (no port input exists)
    es_port = json_inputs['elasticsearch_port']&.first
    self.port = es_port.to_i if es_port
  end

  def test_module
    super
    es_ip = self.json_inputs['elasticsearch_ip']&.first
    es_port = self.json_inputs['elasticsearch_port']&.first

    tier(1) do
      test_local_command('elasticsearch installed?', 'dpkg -l elasticsearch | grep -E "^ii"', 'elasticsearch')
      test_local_command('elastic apt repository configured', 'cat /etc/apt/sources.list.d/elastic-7.x.list', 'artifacts.elastic.co')
      test_local_command('java installed', 'java -version 2>&1', 'version')
      test_local_command('elasticsearch.yml permissions', 'stat -c "%U:%G %a" /etc/elasticsearch/elasticsearch.yml', 'root:elasticsearch 644')
      test_local_command('node name configured', 'cat /etc/elasticsearch/elasticsearch.yml', 'node.name: my_es_node')
      test_local_command('startup timeout drop-in', 'cat /etc/systemd/system/elasticsearch.service.d/startup-timeout.conf', 'TimeoutStartSec=180')
      test_local_command('service enabled', 'systemctl is-enabled elasticsearch', 'enabled')
      test_local_command('service active', 'systemctl is-active elasticsearch | grep -x active', 'active')
      # inputs are rendered into the configuration
      # binds all interfaces: the VLAN IP isn't up at Puppet-apply time; tier 2 checks elasticsearch_ip answers
      test_local_command('network.host binds all interfaces', 'cat /etc/elasticsearch/elasticsearch.yml', 'network.host: 0.0.0.0')
      test_local_command('http.port from elasticsearch_port', 'cat /etc/elasticsearch/elasticsearch.yml', "http.port: #{es_port}") if es_port
    end
    tier(2) do
      test_service_up
      test_http('/', port: self.port, match: 'cluster_name')
      test_http('/', port: self.port, match: 'my_es_node')
      test_http('/_cluster/health', port: self.port, match: 'status')
      # reachable on the configured address as well as via loopback
      if es_ip && es_port
        test_local_command('answers on elasticsearch_ip', "curl -s http://#{es_ip}:#{es_port}/", 'cluster_name')
      end
      # the server binary runs as the service account
      test_local_command('elasticsearch binary runs', '/usr/share/elasticsearch/bin/elasticsearch --version', 'Version: 7.10.0', user: 'elasticsearch')
    end
  end
end

ElasticsearchTest.new.run
