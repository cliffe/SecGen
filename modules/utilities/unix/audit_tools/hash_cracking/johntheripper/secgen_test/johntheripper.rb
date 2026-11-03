require_relative '../../../../../lib/post_provision_test'

class JohntheriperTest < PostProvisionTest
  def initialize
    self.module_name = 'johntheripper'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('john installed?', 'which john', 'john') }
    tier(2) { test_local_command('john shows usage', 'john 2>&1 | head -3', 'John') }
  end
end

JohntheriperTest.new.run
