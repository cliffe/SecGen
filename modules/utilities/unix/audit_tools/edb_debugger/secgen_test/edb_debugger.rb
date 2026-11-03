require_relative '../../../../../lib/post_provision_test'

class EdbDebuggerTest < PostProvisionTest
  def initialize
    self.module_name = 'edb_debugger'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs the package.
  def test_module
    super
    tier(1) { test_local_command('edb-debugger installed?', 'dpkg -l edb-debugger | grep "^ii"', 'edb-debugger') }
    tier(2) do
      # edb is a GUI app; confirm the binary is executable rather than launching it
      test_local_command('edb binary present', 'test -x /usr/bin/edb && echo "ok"', 'ok')
      # no missing shared libraries, checked as an unprivileged user (the loader is the part of a launch that can fail)
      test_command_succeeds('edb has no missing shared libraries', 'test -x /usr/bin/edb && ! ldd /usr/bin/edb | grep -q "not found"', user: 'nobody')
      # --version exits before a window is shown; the offscreen platform lets Qt start without a display
      test_local_command('edb reports its version', 'QT_QPA_PLATFORM=offscreen timeout 30 edb --version 2>&1', 'version', user: 'nobody')
    end
  end
end

EdbDebuggerTest.new.run
