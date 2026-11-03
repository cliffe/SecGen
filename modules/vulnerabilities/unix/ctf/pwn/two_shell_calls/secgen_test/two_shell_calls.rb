require_relative '../../../../../lib/post_provision_test'

class TwoShellCallsTest < PostProvisionTest
  def initialize
    self.module_name = 'two_shell_calls'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # The module creates a 'managers' group and a user account.
      test_local_command('managers group created', 'getent group managers', 'managers')
      test_local_command('user account exists', 'ls -d /home/*/ 2>/dev/null | head -1', '/home/')
    end
    tier(2) do
      # Two SUID binaries are compiled and placed in the user's home.
      test_local_command('SUID binaries present', 'find /home -perm /4000 -type f | wc -l', '1')
    end
    # TODO tier 3 (exploit): deferred — exploit via two-step shell call chain
  end
end

TwoShellCallsTest.new.run
