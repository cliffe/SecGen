require_relative '../../../../../lib/post_provision_test'

class ZenmapTest < PostProvisionTest
  def initialize
    self.module_name = 'zenmap'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('zenmap installed?', 'dpkg -l zenmap | grep "^ii"', 'zenmap') }
    tier(1) { test_local_command('zenmap binary present', 'test -e /usr/bin/zenmap && echo "ok"', 'ok') }
    # zenmap is a GTK GUI with no reliable headless CLI (it imports GTK before parsing
    # arguments, and there is no display), so tier 2 runs nmap, the scanner zenmap drives
    # and depends on, rather than launching zenmap itself
    tier(2) do
      test_command_succeeds('nmap backend runs', 'nmap --version')
      test_local_command('nmap backend scans localhost', 'nmap -sn 127.0.0.1 2>&1', 'Nmap scan report')
    end
  end
end

ZenmapTest.new.run
