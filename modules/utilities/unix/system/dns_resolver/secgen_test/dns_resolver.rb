require_relative '../../../../../lib/post_provision_test'

class DnsResolverTest < PostProvisionTest
  def initialize
    self.module_name = 'dns_resolver'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Tier 1 only: the module configures a file, and whether the nameservers answer depends on
  # the rest of the scenario. The test runs after the build network's teardown and reboot, so
  # these checks also show the setting survived them.
  def test_module
    super
    nameservers = (json_inputs['nameservers'] || []).first(3)
    resolv = run_command('cat /etc/resolv.conf')[:stdout].to_s
    listed = resolv.lines.grep(/^\s*nameserver\s/).map { |l| l.split[1] }

    tier(1) do
      name = 'resolv.conf lists exactly the configured nameservers'
      if listed == nameservers
        pass_check(name, "#{name}: #{listed.join(', ')}")
      else
        fail_check(name, "expected #{nameservers.inspect}, got: #{resolv.strip}"[0, 800])
      end
      name = 'no search domain left from the build network'
      if resolv =~ /^\s*(search|domain)\s/
        fail_check(name, resolv.strip[0, 800])
      else
        pass_check(name)
      end
      test_local_command('dhclient hook in place', 'cat /etc/dhcp/dhclient-enter-hooks.d/secgen-static-resolv', 'make_resolv_conf')
      test_local_command('NetworkManager leaves DNS alone', 'cat /etc/NetworkManager/conf.d/90-secgen-dns-none.conf', 'dns=none')
    end
  end
end

DnsResolverTest.new.run
