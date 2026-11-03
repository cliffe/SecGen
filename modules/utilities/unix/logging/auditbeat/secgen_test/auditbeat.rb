require_relative '../../../../../lib/post_provision_test'

class AuditbeatTest < PostProvisionTest
  def initialize
    self.module_name = 'auditbeat'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    conf = '/etc/auditbeat/auditbeat.yml'
    tier(1) do
      test_local_command('auditbeat installed?', 'dpkg -l auditbeat | grep -E "^ii"', 'auditbeat')
      test_command_succeeds('auditbeat binary present', 'test -x /usr/share/auditbeat/bin/auditbeat')
      test_command_succeeds('auditbeat config present', "test -f #{conf}")
      # the auditd module is enabled and reads the rules directory the module populates
      test_local_command('auditd module enabled', "grep -E 'module: auditd' #{conf}", 'auditd')
      test_command_succeeds('audit rules directory present', 'test -d /etc/auditbeat/audit.rules.d')
      test_local_command('auditbeat enabled at boot', 'systemctl is-enabled auditbeat', 'enabled')
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
      test_command_succeeds('auditbeat service active', 'systemctl is-active auditbeat')
      test_local_command('auditbeat runs', '/usr/share/auditbeat/bin/auditbeat version -c /etc/auditbeat/auditbeat.yml --path.home /usr/share/auditbeat', 'auditbeat')
      test_command_succeeds('auditbeat accepts its config', 'auditbeat test config -c /etc/auditbeat/auditbeat.yml --path.home /usr/share/auditbeat')
    end
  end
end

AuditbeatTest.new.run
