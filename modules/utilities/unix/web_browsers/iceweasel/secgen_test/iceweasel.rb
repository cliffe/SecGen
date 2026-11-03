require_relative '../../../../../lib/post_provision_test'
require 'json'
require 'shellwords'

class IceweaselTest < PostProvisionTest
  def initialize
    self.module_name = 'iceweasel'
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
    disable_proxy = self.json_inputs['disable_proxy']&.first
    disable_https_upgrade = self.json_inputs['disable_https_upgrade']&.first
    # same normalisation as templates/user.js.erb
    homepage = (self.json_inputs['start_page'] || []).map do |p|
      p.start_with?('http') || p.start_with?('file://') ? p : "http://#{p}"
    end.join('|')

    tier(1) do
      # On Debian >=9 and Kali, the package is firefox-esr; on older Debian it was iceweasel
      test_local_command('firefox-esr or iceweasel installed',
        '(which firefox-esr || which iceweasel || which firefox) && echo ok', 'ok')

      if usernames.empty?
        fail_check('accounts input present', 'json_inputs has no parseable accounts', tier: 1)
      end

      usernames.each do |user|
        home = user == 'root' ? '/root' : "/home/#{user}"
        profile = "#{home}/.mozilla/firefox"
        userjs = "#{profile}/user.default/user.js"

        test_local_command("#{user}: profiles.ini present with default profile",
          "grep -c '^Path=user.default$' #{profile}/profiles.ini", '1')
        test_local_command("#{user}: installs.ini present with default profile",
          "grep -c '^Default=user.default$' #{profile}/installs.ini", '1')
        test_local_command("#{user}: profile dir owned by #{user}",
          "stat -c '%U:%G' #{profile}/user.default", "#{user}:#{user}")
        test_local_command("#{user}: user.js present and owned by #{user}",
          "stat -c '%U:%G' #{userjs}", "#{user}:#{user}")

        if !homepage.empty?
          test_local_command("#{user}: user.js start page",
            "grep '^user_pref(\"browser.startup.homepage\"' #{userjs}", "\"#{homepage}\"")
        end

        # disable_proxy true writes proxy type 0; false leaves the proxy settings out
        case disable_proxy
        when 'true'
          test_local_command("#{user}: user.js disables the proxy",
            "grep -c '^user_pref(\"network.proxy.type\", 0);' #{userjs}", '1')
        when 'false'
          test_local_command("#{user}: user.js leaves the proxy alone",
            "{ grep -c 'network.proxy.type' #{userjs} || true; } | grep -x 0", '0')
        end

        # disable_https_upgrade true adds the HTTPS-first overrides; false leaves them out
        case disable_https_upgrade
        when 'true'
          test_local_command("#{user}: user.js disables HTTPS-first upgrades",
            "grep -c '^user_pref(\"dom.security.https_first\", false);' #{userjs}", '1')
        when 'false'
          test_local_command("#{user}: user.js has no HTTPS-first override",
            "{ grep -c 'dom.security.https_first' #{userjs} || true; } | grep -x 0", '0')
        end

        desktop = "#{home}/.config/autostart/iceweasel.desktop"
        case autostart
        when 'true'
          test_local_command("#{user}: autostart entry present",
            "grep -c '^Exec=/usr/bin/firefox$' #{desktop}", '1')
          test_local_command("#{user}: autostart entry owned by #{user}",
            "stat -c '%U:%G' #{desktop}", "#{user}:#{user}")
        when 'false'
          test_local_command("#{user}: no autostart entry",
            "test -e #{desktop} && echo present || echo absent", 'absent')
        end
      end
    end

    tier(2) do
      test_command_succeeds('firefox binary runs (headless version check)',
        'firefox-esr --version 2>/dev/null || iceweasel --version 2>/dev/null || firefox --version 2>/dev/null')
      # run the browser as each configured user, so PATH, libraries and the profile dir are exercised
      usernames.each do |user|
        test_command_succeeds("#{user}: browser runs",
          'firefox-esr --version || iceweasel --version || firefox --version', user: user)
      end
    end
  end
end

IceweaselTest.new.run
