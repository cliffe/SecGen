require_relative '../../../../../lib/post_provision_test'

class LogstashTest < PostProvisionTest
  def initialize
    self.module_name = 'logstash'
    self.module_path = get_module_path(__FILE__)
    super
    # the module's port input is logstash_port, not port
    lp = json_inputs['logstash_port']&.first
    self.port = lp.to_i if lp
  end

  def test_module
    super
    tier(1) do
      test_local_command('logstash installed?', 'dpkg -l logstash | grep -E "^ii"', 'logstash')
      test_local_command('logstash binary present', 'ls /usr/share/logstash/bin/logstash', 'logstash')
      test_local_command('logstash service enabled', 'systemctl is-enabled logstash', 'enabled')
      test_local_command('logstash.yml paths', 'cat /etc/logstash/logstash.yml', '/etc/logstash/conf.d')
      test_local_command('combined_path.rb installed', 'ls /etc/logstash/combined_path.rb', '/etc/logstash/combined_path.rb')
      # the pipeline config holds the configured beats port and Elasticsearch endpoint
      if (lp = json_inputs['logstash_port']&.first)
        test_local_command('pipeline beats port', 'cat /etc/logstash/conf.d/my_ls_config.conf', "port => #{lp}")
      end
      es_ip = json_inputs['elasticsearch_ip']&.first
      es_port = json_inputs['elasticsearch_port']&.first
      if es_ip && es_port
        test_local_command('pipeline elasticsearch output', 'cat /etc/logstash/conf.d/my_ls_config.conf',
                           "#{es_ip}:#{es_port}")
      end
    end
    tier(2) do
      test_local_command('logstash process running?', 'ps -ef | grep "[l]ogstash"', 'logstash')
      # the pipeline runs as the logstash account
      test_local_command('logstash process owner', 'ps -eo user:20,args | grep [l]ogstash', 'logstash')
      test_command_succeeds('logstash service active', 'systemctl is-active logstash')
      # The beats input listens on logstash_port; there is no HTTP endpoint by default
      test_service_up
    end
  end
end

LogstashTest.new.run
