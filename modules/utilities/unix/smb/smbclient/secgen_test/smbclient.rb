require_relative '../../../../../lib/post_provision_test'

class SmbclientTest < PostProvisionTest
  def initialize
    self.module_name = 'smbclient'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('smbclient installed', 'which smbclient', 'smbclient')
      test_local_command('smbclient package installed', 'dpkg -l smbclient | grep -E "^ii"', 'smbclient')
    end
    tier(2) do
      test_local_command('smbclient version', 'smbclient --version', 'Version')
      test_local_command('smbclient version as an unprivileged user', 'smbclient --version', 'Version', user: 'nobody')
      test_command_succeeds('smbclient --help', 'smbclient --help')
    end
  end
end

SmbclientTest.new.run
