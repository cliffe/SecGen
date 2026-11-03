require_relative '../../../../../lib/post_provision_test'

class ChkrootkitTest < PostProvisionTest
  def initialize
    self.module_name = 'chkrootkit'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('chkrootkit installed?', 'which chkrootkit', 'chkrootkit') }
    # chkrootkit -x extracts and shows strings; exit code varies by scan result so check output instead
    tier(2) { test_local_command('chkrootkit runs', 'chkrootkit 2>&1 | head -5', 'Checking') }
  end
end

ChkrootkitTest.new.run
