require_relative '../../../../../lib/post_provision_test'

class MetasploitFrameworkTest < PostProvisionTest
  def initialize
    self.module_name = 'metasploit_framework'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs the package.
  def test_module
    super
    tier(1) do
      test_local_command('metasploit-framework package installed', 'dpkg -l metasploit-framework | grep -E "^ii"', 'metasploit-framework')
      %w[msfconsole msfvenom].each { |bin| test_local_command("#{bin} on PATH", "command -v #{bin}", "/#{bin}") }
    end
    tier(2) do
      test_command_succeeds('msfconsole present', 'test -x /usr/bin/msfconsole')
      # msfconsole loads the whole framework, so this proves the Ruby environment works; it is slow, hence the long
      # timeout. HOME is a scratch directory because the unprivileged user has no writable home.
      # Run it from that home: the guest agent starts commands in /, and bootsnap then
      # scans from there and dies on root-only dirs (opendir /usr/lib/firmware/b43).
      cmd = 'export HOME=$(mktemp -d) TERM=dumb; cd "$HOME"; timeout 180 msfconsole --version 2>&1'
      out = run_as_user('nobody', cmd, timeout: 200)
      if out[:stdout].to_s.include?('Framework Version')
        pass_check('msfconsole --version runs as an unprivileged user')
      else
        fail_check('msfconsole --version runs as an unprivileged user', 'no "Framework Version" in output',
                   evidence: "--- stdout\n#{out[:stdout]}\n--- stderr\n#{out[:stderr]}")
      end
    end
  end
end

MetasploitFrameworkTest.new.run
