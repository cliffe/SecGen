require_relative '../../../../../lib/post_provision_test'

class SudoBaronTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo_baron'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('sudo installed', 'which sudo', '/usr/bin/sudo')
      # sudo_baron installs a specific vulnerable version (1.8.19p1)
      test_local_command('vulnerable sudo version installed', 'dpkg -l sudo | grep -E "^ii"', '1.8.19')
    end
    tier(2) do
      # Vulnerable version should be retained (system upgrade not applied to sudo)
      test_local_command('sudo version not patched', 'sudo --version', '1.8.19')
    end
    # TODO tier 3 (exploit): deferred — heap overflow requires exploit from user account
  end
end

SudoBaronTest.new.run
