require_relative '../../../../../lib/post_provision_test'

class RelativePathSuidHardlinksTest < PostProvisionTest
  def initialize
    self.module_name = 'relative_path_suid_hardlinks'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('user account exists', 'ls -d /home/*/ 2>/dev/null | head -1', '/home/')
      # The module installs a SUID binary via hardlinks.
      test_local_command('SUID binary exists', 'find /home /usr/local -perm /4000 -type f | head -1', '/')
    end
    tier(2) do
      test_local_command('SUID binary is executable', 'find /home /usr/local -perm /4000 -type f -exec test -x {} \\; -print | head -1', '/')
    end
    # TODO tier 3 (exploit): deferred — exploit via relative path resolution with hardlinks
  end
end

RelativePathSuidHardlinksTest.new.run
