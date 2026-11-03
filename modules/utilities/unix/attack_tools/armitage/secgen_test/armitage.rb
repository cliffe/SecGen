require_relative '../../../../../lib/post_provision_test'

class ArmitageTest < PostProvisionTest
  def initialize
    self.module_name = 'armitage'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # No inputs. Armitage itself is a Java GUI with no non-interactive CLI, so tier 2 runs
    # the things it depends on (Java, the VNC viewer, postgres and the msf database).
    tier(1) do
      test_local_command('armitage package installed', 'dpkg -l armitage | grep -E "^ii"', 'armitage')
      test_local_command('xtightvncviewer package installed', 'dpkg -l xtightvncviewer | grep -E "^ii"', 'xtightvncviewer')
      test_local_command('armitage launcher present', 'which armitage', 'armitage')
      test_local_command('postgresql enabled', 'systemctl is-enabled postgresql', 'enabled')
    end
    tier(2) do
      test_command_succeeds('armitage binary present', 'test -x /usr/bin/armitage')
      test_local_command('java runs', 'java -version 2>&1', 'version')
      # xtightvncviewer prints "Can't open display" instead of usage with no X server, so check that
      # the binary resolves and has no missing shared libraries rather than running it.
      test_command_succeeds('vnc viewer binary links cleanly', 'v=$(readlink -f "$(which xtightvncviewer)") && test -x "$v" && ! ldd "$v" 2>&1 | grep -q "not found"')
      test_local_command('postgresql active', 'systemctl is-active postgresql | grep -x active', 'active')
      # msfdb reinit created the msf database
      test_local_command('msf database exists', 'runuser -u postgres -- psql -lqt', 'msf')
    end
  end
end

ArmitageTest.new.run
