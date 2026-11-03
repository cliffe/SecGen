require_relative '../../../../../lib/post_provision_test'

class SudoeditTest < PostProvisionTest
  def initialize
    self.module_name = 'sudoedit'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('sudo installed', 'which sudo', '/usr/bin/sudo')
      # sudoedit module installs sudo 1.8.26 (vulnerable to CVE-2021-3156)
      test_local_command('vulnerable sudo version installed', 'dpkg -l sudo | grep -E "^ii"', '1.8.26')
    end
    tier(2) do
      # The sudoedit rule: ALL ALL = (root) NOPASSWD: sudoedit /etc/hosts
      test_local_command('sudoedit rule present', 'grep "sudoedit /etc/hosts" /etc/sudoers', 'sudoedit')
    end
    # TODO tier 3 (exploit): deferred — sudoedit heap overflow requires interactive exploit
  end
end

SudoeditTest.new.run
