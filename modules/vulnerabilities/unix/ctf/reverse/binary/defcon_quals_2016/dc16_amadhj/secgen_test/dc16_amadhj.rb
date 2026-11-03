require_relative '../../../../../lib/post_provision_test'

class Dc16AmadhJTest < PostProvisionTest
  def initialize
    self.module_name = 'dc16_amadhj'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # Binary is installed as SUID/SGID via secgen_functions::install_setuid_root_binary.
      test_local_command('dc16_amadhj binary exists', 'find /usr/local/bin /home -name "dc16_amadhj" -o -name "amadhj" 2>/dev/null | head -1', '/')
    end
    tier(2) do
      test_local_command('binary is executable', 'find /usr/local/bin /home -name "dc16_amadhj" -o -name "amadhj" 2>/dev/null | xargs -I{} test -x {} 2>/dev/null && echo ok', 'ok')
      test_local_command('SUID or SGID bit set', 'find /usr/local/bin /home -name "amadhj" -perm /6000 2>/dev/null | head -1', '/')
    end
    # TODO tier 3 (exploit): deferred — reverse engineering / binary exploitation challenge
  end
end

Dc16AmadhJTest.new.run
