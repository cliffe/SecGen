require_relative '../../../../../lib/post_provision_test'

class DisableAslrTest < PostProvisionTest
  def initialize
    self.module_name = 'disable_aslr'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_command_succeeds('ASLR sysctl config exists',
                            'test -f /etc/sysctl.d/01-disable-aslr.conf')
      test_local_command('ASLR config has correct value',
                         'cat /etc/sysctl.d/01-disable-aslr.conf',
                         'randomize_va_space = 0')
      test_local_command('ASLR config sets the kernel parameter',
                         'cat /etc/sysctl.d/01-disable-aslr.conf', 'kernel.randomize_va_space')
    end
    tier(2) do
      # Verify the kernel parameter is actually 0 after boot/sysctl apply
      test_local_command('ASLR disabled at runtime',
                         'cat /proc/sys/kernel/randomize_va_space',
                         '0')
      test_local_command('sysctl reports ASLR value exactly 0',
                         '[ "$(sysctl -n kernel.randomize_va_space)" = 0 ] && echo ok', 'ok')
      # with ASLR off the stack end address is the same in two separate processes
      test_local_command('stack address is not randomised',
                         'a=$(grep "\[stack\]" /proc/self/maps | cut -d" " -f1 | cut -d- -f2); ' \
                         'b=$(bash -c \'grep "\\[stack\\]" /proc/self/maps | cut -d" " -f1 | cut -d- -f2\'); ' \
                         '[ -n "$a" ] && [ "$a" = "$b" ] && echo ok',
                         'ok')
    end
  end
end

DisableAslrTest.new.run
