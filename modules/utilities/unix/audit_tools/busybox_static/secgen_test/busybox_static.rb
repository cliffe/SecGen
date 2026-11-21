require_relative '../../../../../lib/post_provision_test'

class BusyboxStaticTest < PostProvisionTest
  def initialize
    self.module_name = 'busybox_static'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('busybox installed?',
                         'test -x /bin/busybox && echo ok', 'ok')
    end

    tier(2) do
      # The whole point of this module: the binary is statically linked, so it
      # never loads the host's shared libraries or the dynamic loader. ldd on a
      # static binary prints this on a line that does not contain "busybox", so
      # matching stderr here cannot false-positive on the program's own name.
      test_local_command('busybox is statically linked?',
                         'ldd /bin/busybox 2>&1', 'not a dynamic executable')
      # A trusted applet actually runs (reads /proc directly, independent of the
      # host's own ps/ls and of any shell aliases a userland rootkit installs).
      test_command_succeeds('busybox ps runs?', '/bin/busybox ps >/dev/null')
    end
  end
end

BusyboxStaticTest.new.run
