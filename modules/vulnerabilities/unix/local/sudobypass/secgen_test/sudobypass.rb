require_relative '../../../../../lib/post_provision_test'

class SudobypassTest < PostProvisionTest
  def initialize
    self.module_name = 'sudobypass'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('sudo installed', 'which sudo', '/usr/bin/sudo')
    end
    tier(2) do
      # The bypass rule: ALL ALL=(ALL,!root) /bin/bash must be present
      test_local_command('bypass sudoers rule present', 'grep "ALL,!root" /etc/sudoers', '!root')
    end
    # TODO tier 3 (exploit): deferred — run as low-priv user: sudo -u#-1 /bin/bash
  end
end

SudobypassTest.new.run
