require_relative '../../../../../lib/post_provision_test'

class SimpleBofTest < PostProvisionTest
  def initialize
    self.module_name = 'simple_bof'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('gcc installed', 'which gcc', 'gcc')
      # The vulnerable C source and compiled binary are placed in /root (default).
      test_local_command('simple_bof source placed', 'test -f /root/simple_bof.c && echo ok', 'ok')
    end
    tier(2) do
      # The binary is compiled and executable.
      test_local_command('binary compiled', 'find /root /home -name "simple_bof" -type f | head -1', '/')
      test_local_command('binary is executable', 'find /root /home -name "simple_bof" -perm /0111 | head -1', '/')
    end
    # TODO tier 3 (exploit): deferred — exploit via stack buffer overflow
  end
end

SimpleBofTest.new.run
