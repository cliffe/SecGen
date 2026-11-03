# just the puppet module
require_relative '../../../../../lib/post_provision_test'

# The 'firewall' module is the upstream puppetlabs/firewall Puppet module that
# provides the firewall resource type used by other SecGen modules. Its only
# observable effect on the system is ensuring iptables is present and loaded.
class FirewallTest < PostProvisionTest
  def initialize
    self.module_name = 'firewall'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # no inputs to check: the module takes none
    tier(1) do
      test_local_command('iptables installed', 'which iptables', 'iptables')
      test_local_command('iptables package installed', 'dpkg -l iptables | grep -E "^ii"', 'iptables')
      # on Debian the module also installs iptables-persistent (service: netfilter-persistent)
      test_local_command('iptables-persistent installed', 'dpkg -l iptables-persistent | grep -E "^ii"', 'iptables-persistent')
      test_local_command('netfilter-persistent enabled', 'systemctl is-enabled netfilter-persistent', 'enabled')
    end
    tier(2) do
      test_command_succeeds('iptables runs', 'iptables --version')
      test_local_command('iptables lists chains', 'iptables -L -n', 'Chain INPUT')
      test_command_succeeds('iptables-save runs', 'iptables-save')
      test_command_succeeds('netfilter-persistent runs', 'netfilter-persistent --help || netfilter-persistent save')
    end
  end
end

FirewallTest.new.run
