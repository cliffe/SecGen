require_relative '../../../../../lib/post_provision_test'

class ThunderbirdTest < PostProvisionTest
  def initialize
    self.module_name = 'thunderbird'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    usernames = (self.json_inputs['accounts'] || []).map do |raw|
      begin
        JSON.parse(raw)['username']
      rescue JSON::ParserError
        nil
      end
    end.compact
    autostart = self.json_inputs['autostart']&.first

    # start_page is skipped: the Puppet reads it but never writes it anywhere, so there is nothing on the box to check.
    tier(1) do
      test_local_command('thunderbird installed?', 'dpkg -l thunderbird | grep -E "^ii"', 'thunderbird')
      test_local_command('thunderbird binary on PATH', 'command -v thunderbird', 'thunderbird')

      usernames.each do |user|
        home = "/home/#{user}"
        # per-account profile, owned by the account
        test_local_command("#{user} profile directory owner", "stat -c '%U' #{home}/.thunderbird/user.default", user)
        test_local_command("#{user} profiles.ini names the default profile", "cat #{home}/.thunderbird/profiles.ini", 'Path=user.default')
        # user.js is templated from the account name: mail identity, server login and mail root
        test_local_command("#{user} user.js identity", "cat #{home}/.thunderbird/user.default/user.js",
                           "\"mail.identity.id1.useremail\", \"#{user}@localhost\"")
        test_local_command("#{user} user.js server login", "cat #{home}/.thunderbird/user.default/user.js",
                           "\"mail.server.server1.userName\", \"#{user}\"")
        test_local_command("#{user} user.js mail root", "cat #{home}/.thunderbird/user.default/user.js",
                           "\"mail.root.pop3\", \"#{home}/.thunderbird/user.default/Mail\"")
        # autostart: desktop entry present only when true
        if autostart
          entry = "#{home}/.config/autostart/thunderbird.desktop"
          if autostart == 'true'
            test_local_command("#{user} autostart entry", "stat -c '%U %n' #{entry}", "#{user} #{entry}")
          else
            test_command_succeeds("#{user} has no autostart entry", "! test -e #{entry}", tier: 1)
          end
        end
      end
    end

    tier(2) do
      test_command_succeeds('thunderbird binary exists', 'test -x /usr/bin/thunderbird')
      (usernames.empty? ? [nil] : usernames).each do |user|
        test_local_command("thunderbird runs#{user ? " as #{user}" : ''}", 'thunderbird --version', 'Thunderbird', user: user)
      end
    end
  end
end

ThunderbirdTest.new.run
