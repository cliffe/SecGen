require_relative '../../../../../lib/post_provision_test'

class HashcatTest < PostProvisionTest
  def initialize
    self.module_name = 'hashcat'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('hashcat installed?', 'which hashcat', 'hashcat') }
    tier(2) { test_command_succeeds('hashcat reports version', 'hashcat --version') }
  end
end

HashcatTest.new.run
