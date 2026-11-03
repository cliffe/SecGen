require_relative '../../../../../lib/post_provision_test'

class SambaTest < PostProvisionTest
  def initialize
    self.module_name = 'samba'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 139 # NetBIOS session port; the module has no inputs
  end

  def test_module
    super
    tier(1) do
      test_local_command('samba installed?', 'dpkg -l samba | grep -E "^ii"', 'samba')
      test_local_command('smbd binary present', 'which smbd', 'smbd')
      test_local_command('nmbd binary present', 'which nmbd', 'nmbd')
      test_local_command('smb.conf present', 'cat /etc/samba/smb.conf', '[global]')
    end
    tier(2) do
      test_service_up
      test_service_up(port: 445)
      test_command_succeeds('smb.conf parses', 'testparm -s')
      test_local_command('smbd runs', 'smbd --version', 'Version')
      test_local_command('nmbd runs', 'nmbd --version', 'Version')
      test_command_succeeds('smbd service active', 'systemctl is-active smbd')
    end
  end
end

SambaTest.new.run
