require_relative '../../../../../lib/post_provision_test'

class KaliForensicTest < PostProvisionTest
  def initialize
    self.module_name = 'kali_forensic'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # No inputs. The module only installs the kali-tools-forensics metapackage.
    tier(1) do
      test_local_command('kali-tools-forensics installed', 'dpkg -l kali-tools-forensics | grep -E "^ii"', 'kali-tools-forensics')
      test_local_command('foremost on PATH', 'which foremost', 'foremost')
      test_local_command('binwalk on PATH', 'which binwalk', 'binwalk')
      test_local_command('sleuthkit fls on PATH', 'which fls', 'fls')
    end
    tier(2) do
      test_command_succeeds('foremost available', 'foremost -V')
      test_command_succeeds('binwalk runs', 'binwalk --help')
      test_command_succeeds('fls runs', 'fls -V')
    end
  end
end

KaliForensicTest.new.run
