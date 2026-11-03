require_relative '../../../../../lib/post_provision_test'

class Dc16B3s23Test < PostProvisionTest
  def initialize
    self.module_name = 'dc16_b3s23'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('dc16_b3s23 binary exists', 'find /usr/local/bin /home -name "dc16_b3s23" -o -name "b3s23" 2>/dev/null | head -1', '/')
    end
    tier(2) do
      test_local_command('SUID or SGID bit set', 'find /usr/local/bin /home -name "b3s23" -perm /6000 2>/dev/null | head -1', '/')
    end
    # TODO tier 3 (exploit): deferred — reverse engineering / binary exploitation challenge
  end
end

Dc16B3s23Test.new.run
