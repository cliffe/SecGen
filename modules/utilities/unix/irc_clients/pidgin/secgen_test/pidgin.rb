require_relative '../../../../../lib/post_provision_test'

class PidginTest < PostProvisionTest
  def initialize
    self.module_name = 'pidgin'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    accounts = (self.json_inputs['accounts'] || []).map { |raw| JSON.parse(raw) }
    server_ip = self.json_inputs['server_ip']&.first
    autostart = self.json_inputs['autostart']&.first.to_s == 'true'

    tier(1) do
      test_local_command('pidgin installed?', 'dpkg -l pidgin | grep -E "^ii"', 'pidgin')
      test_local_command('pidgin on PATH', 'which pidgin', '/usr/bin/pidgin')
    end

    # Per-account configuration written by pidgin::config.
    accounts.each do |account|
      username = account['username']
      next unless username
      home = username == 'root' ? '/root' : "/home/#{username}"
      conf = "#{home}/.purple"

      tier(1) do
        %w[accounts.xml blist.xml pounces.xml prefs.xml status.xml icons/skullandusb.svg].each do |file|
          test_local_command("#{username}: #{file} present", "test -s #{conf}/#{file} && echo present", 'present')
        end
        test_local_command("#{username}: .purple owned by the account", "stat -c %U #{conf}", username)

        # The IRC account is "<username>@<server_ip>"; server_ip is checked
        # through it, as it appears in each of the three templated files.
        if server_ip
          %w[accounts.xml blist.xml pounces.xml].each do |file|
            test_local_command("#{username}: #{file} uses #{username}@#{server_ip}",
                               "grep -F '#{username}@#{server_ip}' #{conf}/#{file}", "#{username}@#{server_ip}")
          end
        end

        # autostart is only written when the input is true
        if autostart
          test_local_command("#{username}: autostart entry", "cat #{home}/.config/autostart/pidgin.desktop", 'Exec=/usr/bin/pidgin')
        end
      end

      # The client starts for this account (no display needed for --version).
      tier(2) { test_command_succeeds("pidgin runs for #{username}", 'pidgin --version', user: username) }
    end

    # No accounts supplied: still prove the binary runs.
    tier(2) do
      test_local_command('pidgin reports its version', 'pidgin --version', 'Pidgin')
      test_command_succeeds('pidgin binary exists', 'test -x /usr/bin/pidgin')
    end
  end
end

PidginTest.new.run
