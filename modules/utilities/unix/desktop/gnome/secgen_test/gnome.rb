require_relative '../../../../../lib/post_provision_test'

class GnomeTest < PostProvisionTest
  def initialize
    self.module_name = 'gnome'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('task-gnome-desktop installed?', 'dpkg -l task-gnome-desktop | grep -E "^ii"', 'task-gnome-desktop') }
    tier(1) do
      # task-gnome-desktop pulls in the shell and the gdm3 login manager
      test_local_command('gdm3 installed?', 'dpkg -l gdm3 | grep -E "^ii"', 'gdm3')
      test_local_command('gnome-shell installed?', 'dpkg -l gnome-shell | grep -E "^ii"', 'gnome-shell')
    end
    # no inputs to check: the module takes none
    tier(2) do
      test_command_succeeds('gnome-shell binary exists', 'test -x /usr/bin/gnome-shell')
      test_local_command('gnome-shell runs', 'gnome-shell --version', 'GNOME Shell')
      test_command_succeeds('gdm3 service enabled', 'systemctl is-enabled gdm3 || systemctl is-enabled display-manager')
    end
  end
end

GnomeTest.new.run
