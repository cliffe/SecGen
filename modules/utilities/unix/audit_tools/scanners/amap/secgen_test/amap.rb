require_relative '../../../../../lib/post_provision_test'

class AmapTest < PostProvisionTest
  def initialize
    self.module_name = 'amap'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('amap installed?', 'which amap', 'amap') }
    # amap exits non-zero without args but prints usage to stderr; test_local_command checks stdout OR stderr
    tier(2) { test_local_command('amap responds', 'command -v amap >/dev/null && amap 2>&1 | head -3', 'amap') }
  end
end

AmapTest.new.run
