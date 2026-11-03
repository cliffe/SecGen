require_relative '../../../../../lib/post_provision_test'

class SshRootLoginTest < PostProvisionTest
  def initialize
    self.module_name = 'ssh_root_login'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('openssh-server installed', 'dpkg -l openssh-server | grep -E "^ii"', 'openssh-server')
      test_service_up(port: 22)
    end
    tier(2) do
      test_local_command('PermitRootLogin enabled', 'grep "^PermitRootLogin yes" /etc/ssh/sshd_config', 'PermitRootLogin yes')
    end
    # TODO tier 3 (exploit): deferred — wire up test_msf_exploit when attacker VM is available
  end
end

SshRootLoginTest.new.run
