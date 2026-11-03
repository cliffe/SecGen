require_relative '../../../../../lib/post_provision_test'

class SudoTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('sudo binary present', 'which sudo', '/usr/bin/sudo')
      test_local_command('visudo present', 'command -v visudo', 'visudo')
      test_local_command('sudoers.d directory present', 'test -d /etc/sudoers.d && echo ok', 'ok')
    end
    tier(2) do
      test_command_succeeds('sudo version runs', 'sudo --version')
      test_local_command('sudoers file present', 'test -f /etc/sudoers && echo ok', 'ok')
      test_local_command('sudoers syntax valid', 'visudo -c 2>&1', 'parsed OK')
      test_command_succeeds('sudo runs a command as root', 'sudo -n id -u')
      test_command_succeeds('sudo --version runs as an unprivileged user', 'sudo --version', user: 'nobody')
    end
  end
end

SudoTest.new.run
