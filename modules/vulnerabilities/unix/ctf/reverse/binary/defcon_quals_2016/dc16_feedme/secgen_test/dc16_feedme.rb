require_relative '../../../../../lib/post_provision_test'

class Dc16FeedmeTest < PostProvisionTest
  def initialize
    self.module_name = 'dc16_feedme'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('dc16_feedme binary exists', 'find /usr/local/bin /home -name "dc16_feedme" -o -name "feedme" 2>/dev/null | head -1', '/')
    end
    tier(2) do
      test_local_command('SUID or SGID bit set', 'find /usr/local/bin /home -name "feedme" -perm /6000 2>/dev/null | head -1', '/')
    end
    # TODO tier 3 (exploit): deferred — reverse engineering / binary exploitation challenge
  end
end

Dc16FeedmeTest.new.run
