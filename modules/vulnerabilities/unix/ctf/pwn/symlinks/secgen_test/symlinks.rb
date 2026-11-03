require_relative '../../../../../lib/post_provision_test'

class SymlinksTest < PostProvisionTest
  def initialize
    self.module_name = 'symlinks'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('user account exists', 'ls -d /home/*/ 2>/dev/null | head -1', '/home/')
      # The challenge creates symlinks in the user's home directory.
      test_local_command('symlink present', 'find /home -type l | head -1', '/')
    end
    tier(2) do
      # The symlink target should be reachable (no dangling links means the target file also exists).
      test_local_command('symlink not dangling', 'find /home -type l | head -1 | xargs -I{} test -e "{}" && echo ok', 'ok')
    end
    # TODO tier 3 (exploit): deferred — exploit via symlink race or file permission bypass
  end
end

SymlinksTest.new.run
