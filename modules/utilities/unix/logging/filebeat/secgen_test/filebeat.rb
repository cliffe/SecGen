require_relative '../../../../../lib/post_provision_test'

class FilebeatTest < PostProvisionTest
  def initialize
    self.module_name = 'filebeat'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    conf = '/etc/filebeat/filebeat.yml'
    tier(1) do
      test_local_command('filebeat installed?', 'dpkg -l filebeat | grep -E "^ii"', 'filebeat')
      test_command_succeeds('filebeat binary present', 'test -x /usr/share/filebeat/bin/filebeat')
      test_command_succeeds('filebeat config present', "test -f #{conf}")
      # the syslogs prospector the module adds ships the auth and syslog files
      test_local_command('auth.log is shipped', "grep -rF '/var/log/auth.log' /etc/filebeat", '/var/log/auth.log')
      test_local_command('syslog is shipped', "grep -rF '/var/log/syslog' /etc/filebeat", '/var/log/syslog')
      test_local_command('filebeat enabled at boot', 'systemctl is-enabled filebeat', 'enabled')
      # logstash_ip / logstash_port: the output points at the configured logstash
      ip = self.json_inputs['logstash_ip']&.first
      lport = self.json_inputs['logstash_port']&.first
      if ip && lport
        test_local_command('logstash output configured', "grep -F '#{ip}:#{lport}' #{conf}", "#{ip}:#{lport}")
      elsif ip
        test_local_command('logstash host configured', "grep -F '#{ip}' #{conf}", ip)
      elsif lport
        test_local_command('logstash port configured', "grep -F ':#{lport}' #{conf}", ":#{lport}")
      end
    end
    tier(2) do
      test_command_succeeds('filebeat service active', 'systemctl is-active filebeat')
      test_local_command('filebeat runs', 'filebeat version', 'filebeat')
      test_command_succeeds('filebeat accepts its config', "filebeat test config -c #{conf}")
    end
  end
end

FilebeatTest.new.run
