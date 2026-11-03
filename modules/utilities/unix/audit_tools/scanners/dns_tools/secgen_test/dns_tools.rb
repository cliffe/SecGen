require_relative '../../../../../lib/post_provision_test'

class DnsToolsTest < PostProvisionTest
  def initialize
    self.module_name = 'dns_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('dig installed?', 'which dig', 'dig')
      test_local_command('dnstracer installed?', 'which dnstracer', 'dnstracer')
      # the module enables DNS host-name resolution in nsswitch.conf
      test_local_command('nsswitch resolves hosts via dns', "grep '^hosts:' /etc/nsswitch.conf", 'dns')
    end
    # dig -v prints "DiG <version>" to stderr, hence 2>&1
    tier(2) do
      test_local_command('dig reports version', 'dig -v 2>&1', 'DiG')
      test_local_command('dnstracer runs', 'command -v dnstracer >/dev/null && dnstracer 2>&1', 'dnstracer')
    end

    # the extra enumeration tools are installed on Kali only, as in the Puppet
    if run_vagrant_ssh('. /etc/os-release; echo "$ID"')[:stdout].strip == 'kali'
      { 'dnsenum' => '--help', 'dnsmap' => '', 'dnsrecon' => '--help', 'fierce' => '--help' }.each do |tool, arg|
        tier(1) { test_local_command("#{tool} installed?", "which #{tool}", tool) }
        tier(2) { test_local_command("#{tool} runs", "command -v #{tool} >/dev/null && #{tool} #{arg} 2>&1 | head -20", tool) }
      end
    end
  end
end

DnsToolsTest.new.run
