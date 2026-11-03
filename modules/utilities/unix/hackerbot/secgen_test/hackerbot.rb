require_relative '../../../../../lib/post_provision_test'
require 'digest'

class HackerbotTest < PostProvisionTest
  def initialize
    self.module_name = 'hackerbot'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # hackerbot_configs: JSON strings, each with the bot's xml_config, written to config/bot_<n>.xml
    configs = (self.json_inputs['hackerbot_configs'] || []).map do |raw|
      begin
        JSON.parse(raw)['xml_config']
      rescue JSON::ParserError, TypeError
        nil
      end
    end
    # ssh_key_pair: JSON string; the private key is installed for the bot's SSH connections
    private_key = begin
      JSON.parse(self.json_inputs['ssh_key_pair']&.first.to_s)['private'].to_s
    rescue JSON::ParserError
      ''
    end
    # server_ip is skipped: the IRC server belongs to another system and the unit's ExecStart does not pass it to the bot.

    tier(1) do
      test_local_command('hackerbot directory exists', 'test -d /opt/hackerbot && echo ok', 'ok')
      test_local_command('hackerbot.rb present', 'test -f /opt/hackerbot/hackerbot.rb && echo ok', 'ok')
      test_local_command('/opt/hackerbot is root-owned mode 700', "stat -c '%U:%G %a' /opt/hackerbot", 'root:root 700')
      test_local_command('hackerbot AIML data present', 'ls /opt/hackerbot/config/AIML', 'alice.aiml')
      test_local_command('cinch gem installed', 'gem list | grep -E "^cinch"', 'cinch')
      test_local_command('nokogiri gem installed', 'gem list | grep -E "^nokogiri"', 'nokogiri')
      %w[nori programr thwait].each do |gem_name|
        test_local_command("#{gem_name} gem installed", "gem list | grep -E '^#{gem_name}'", gem_name)
      end
      test_local_command('sshpass installed', 'which sshpass', 'sshpass')
      test_local_command('hackerbot.service unit present', 'test -e /etc/systemd/system/hackerbot.service && echo ok', 'ok')
      test_local_command('SSH key dir is mode 700', "stat -c '%a' /opt/hackerbot/keys", '700')
      test_local_command('SSH private key is mode 600', "stat -c '%U %a' /opt/hackerbot/keys/id_rsa", 'root 600')
      unless private_key.strip.empty?
        test_local_command('SSH private key content matches the supplied key',
                           'sha256sum /opt/hackerbot/keys/id_rsa', Digest::SHA256.hexdigest(private_key))
      end
      configs.each_with_index do |xml, i|
        next if xml.nil?
        file = "/opt/hackerbot/config/bot_#{i}.xml"
        test_local_command("bot_#{i}.xml is root-owned mode 600", "stat -c '%U:%G %a' #{file}", 'root:root 600')
        test_local_command("bot_#{i}.xml content matches the config",
                           "sha256sum #{file}", Digest::SHA256.hexdigest(xml))
      end
    end
    tier(2) do
      # Hackerbot runs as a systemd service; it connects outbound via IRC so there is no inbound port to probe
      test_command_succeeds('hackerbot service enabled', 'systemctl is-enabled hackerbot')
      test_local_command('hackerbot service unit present', 'test -f /etc/systemd/system/hackerbot.service && echo ok', 'ok')
      test_local_command('hackerbot service is active', 'systemctl is-active hackerbot | grep -x active', 'active')
      # the script parses, and the gems it needs load (running it would start the bots)
      test_command_succeeds('hackerbot.rb parses', 'ruby -c /opt/hackerbot/hackerbot.rb')
      test_command_succeeds('hackerbot gems load', "ruby -e 'require \"cinch\"; require \"nokogiri\"; require \"programr\"; require \"nori\"'")
      configs.each_with_index do |xml, i|
        next if xml.nil?
        test_command_succeeds("bot_#{i}.xml is well-formed XML", "ruby -rnokogiri -e 'Nokogiri::XML(File.read(\"/opt/hackerbot/config/bot_#{i}.xml\")) { |c| c.strict }'")
      end
    end
  end
end

HackerbotTest.new.run
