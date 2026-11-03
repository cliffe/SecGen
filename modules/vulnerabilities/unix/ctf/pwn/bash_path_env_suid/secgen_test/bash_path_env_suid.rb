require_relative '../../../../../lib/post_provision_test'

class BashPathEnvSuidTest < PostProvisionTest
  def initialize
    self.module_name = 'bash_path_env_suid'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # An account is created and a SUID binary (access_my_flag) compiled into their home.
      test_local_command('user account exists', 'ls -d /home/*/ 2>/dev/null | head -1', '/home/')
      test_local_command('access_my_flag compiled', 'find /home -name "access_my_flag" | head -1', 'access_my_flag')
    end
    tier(2) do
      # The binary must have the SUID bit set (executes as owner).
      test_local_command('access_my_flag has SUID bit', 'find /home -name "access_my_flag" -perm /4000 | head -1', 'access_my_flag')
    end
    # TODO tier 3 (exploit): deferred — exploit via PATH environment variable manipulation
  end
end

BashPathEnvSuidTest.new.run
