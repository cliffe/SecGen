require_relative '../../../../../lib/post_provision_test'

class AptUpgradeTest < PostProvisionTest
  def initialize
    self.module_name = 'apt_upgrade'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('apt binary present', 'which apt-get', 'apt-get') }
    # The puppet-agent hold is not checked: the module skips the whole upgrade (and the hold)
    # when dirtycow is in the scenario, and only applies it on Debian.
    tier(2) do
      # apt-get upgrade runs idempotently; after provisioning the system should be at latest versions
      test_command_succeeds('apt-get check passes', 'apt-get check')
      # an upgrade interrupted part-way leaves packages half-configured
      test_local_command('dpkg has no broken packages', 'test -z "$(dpkg --audit)" && echo clean', 'clean')
      # apt can still plan an upgrade against the refreshed lists
      test_command_succeeds('apt-get upgrade simulation runs', 'apt-get -s upgrade')
    end
  end
end

AptUpgradeTest.new.run
