require_relative '../../../../../lib/post_provision_test'

class IRC2Test < PostProvisionTest
  def initialize
    self.module_name = 'irc2'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 6667 # module has no port input; fixed by the P line in files/ircd.conf
  end

  def test_module
    super
    motd = self.json_inputs['motd']&.first
    tier(1) do
      test_local_command('ircd-irc2 package', 'dpkg -s ircd-irc2', 'Status: install ok installed')
      test_local_command('/etc/ircd/ircd.conf deployed', 'cat /etc/ircd/ircd.conf', 'Fast IRC Server')
      test_local_command('/etc/ircd/ircd.motd from motd input', 'cat /etc/ircd/ircd.motd', motd) if motd
      test_local_command('service enabled', 'systemctl is-enabled ircd-irc2', 'enabled')
      test_local_command('service active', 'systemctl is-active ircd-irc2 | grep -x active', 'active')
    end
    tier(2) do
      test_service_up
      # a client can register and gets the welcome numeric from the configured server
      test_local_command('IRC registration welcomed',
                         %q(timeout 10 bash -c 'exec 3<>/dev/tcp/127.0.0.1/6667; printf "NICK secgen\r\nUSER secgen 0 * :secgen\r\n" >&3; timeout 3 cat <&3' 2>/dev/null | head -c 2000),
                         ' 001 ')
      test_remote_irc_client
    end
  end

  # A real IRC client (weechat) on the attacker VM connects over the scenario
  # network and must get the server's welcome. weechat is driven headless
  # through `script` and its server-buffer log is read back.
  def test_remote_irc_client
    name = 'weechat on attacker registers with the server'
    attacker = attack_system
    return skip_check(name, 'no attacker VM in the project', tier: 2) unless attacker
    unless run_on_system(attacker, 'command -v weechat')[:stdout].include?('weechat')
      return skip_check(name, "weechat not installed on #{attacker}", tier: 2)
    end
    cmd = <<~SH
      d=$(mktemp -d); export HOME=/root TERM=xterm-256color
      timeout 40 script -qfec "weechat -d $d -r '/server add secgen #{system_ip}/#{self.port} -notls -nicks=wcsecgen;/connect secgen;/wait 8 /quit'" /dev/null >/dev/null 2>&1
      find $d -name 'irc.server.secgen.*' -exec cat {} +
      rm -rf $d
    SH
    out = run_on_system(attacker, cmd, timeout: 60)
    if out[:stdout].include?('Welcome to the Internet Relay Network')
      pass_check(name, "#{name} at #{system_ip}:#{self.port} from #{attacker}", tier: 2)
    else
      fail_check(name, "#{name} at #{system_ip}:#{self.port} from #{attacker}", tier: 2,
                 evidence: "--- weechat server log\n#{out[:stdout]}\n--- stderr\n#{out[:stderr]}")
    end
  end
end

IRC2Test.new.run
