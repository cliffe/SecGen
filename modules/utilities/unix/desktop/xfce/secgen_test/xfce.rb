require_relative '../../../../../lib/post_provision_test'

class XfceTest < PostProvisionTest
  def initialize
    self.module_name = 'xfce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # no inputs to check: the module takes none
    tier(1) do
      test_local_command('xfce4 installed?', 'dpkg -l xfce4 | grep -E "^ii"', 'xfce4')
      test_local_command('lightdm installed?', 'dpkg -l lightdm | grep -E "^ii"', 'lightdm')
    end
    tier(2) do
      test_command_succeeds('xfce4-session binary exists', 'test -x /usr/bin/xfce4-session')
      test_local_command('xfce4-session runs', 'xfce4-session --version', 'xfce4-session')
      test_command_succeeds('lightdm runs', 'lightdm --version')
      test_command_succeeds('display manager unit is present', 'systemctl cat lightdm >/dev/null')
    end
  end
end

XfceTest.new.run
