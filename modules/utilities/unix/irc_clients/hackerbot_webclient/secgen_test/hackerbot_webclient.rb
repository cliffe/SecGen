require_relative '../../../../../lib/post_provision_test'
require 'json'

class HackerbotWebclientTest < PostProvisionTest
  # The Puppet unit serves the client on a fixed port; it is not a module input.
  WEB_PORT = 8080

  def initialize
    self.module_name = 'hackerbot_webclient'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['username']&.first
    server_ip = self.json_inputs['irc_server_ip']&.first
    nick = self.json_inputs['hackerbot_nick']&.first
    # config.js bakes in all three inputs; the IRC server itself is on another system, so only the baked-in value is checked.
    expected = []
    expected << ['NICK (username)', "var NICK = #{username.to_json};"] if username
    expected << ['TARGET (hackerbot_nick)', "var TARGET = #{nick.to_json};"] if nick
    expected << ['WS_URL (irc_server_ip)', "var WS_URL = \"ws://\" + #{server_ip.to_json} + \":8097/\";"] if server_ip

    tier(1) do
      test_local_command('python3 installed?', 'which python3', '/usr/bin/python3')
      test_local_command('/opt/hackerbot_webclient directory exists?', 'test -d /opt/hackerbot_webclient && echo ok', 'ok')
      %w[index.html app.js config.js].each do |f|
        test_local_command("#{f} installed, root-owned, mode 644", "stat -c '%U:%G %a' /opt/hackerbot_webclient/#{f}", 'root:root 644')
      end
      test_local_command('serve.py installed, root-owned, mode 755', "stat -c '%U:%G %a' /opt/hackerbot_webclient/serve.py", 'root:root 755')
      expected.each do |label, line|
        test_local_command("config.js sets #{label}", 'cat /opt/hackerbot_webclient/config.js', line)
      end
      test_local_command('hackerbot-webclient unit present', 'test -f /etc/systemd/system/hackerbot-webclient.service && echo ok', 'ok')
    end
    tier(2) do
      test_command_succeeds('python3 runs', 'python3 --version')
      test_local_command('hackerbot-webclient service is active', 'systemctl is-active hackerbot-webclient | grep -x active', 'active')
      test_local_command('hackerbot-webclient service is enabled', 'systemctl is-enabled hackerbot-webclient', 'enabled')
      test_service_up(port: WEB_PORT)
      test_http('/', port: WEB_PORT, match: '<title>Hackerbot</title>')
      test_http('/app.js', port: WEB_PORT, status: 200)
      # the served config.js carries the per-lab values
      expected.each do |label, line|
        test_http('/config.js', port: WEB_PORT, match: line, label: "served config.js sets #{label}")
      end
    end
  end
end

HackerbotWebclientTest.new.run
