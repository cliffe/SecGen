require_relative '../../../../../lib/post_provision_test'

class DisableKaslrTest < PostProvisionTest
  def initialize
    self.module_name = 'disable_kaslr'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_command_succeeds('nokaslr helper script installed',
                            'test -x /usr/local/sbin/secgen-enable-nokaslr')
      test_local_command('nokaslr added to the GRUB command line',
                         'grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub',
                         'nokaslr')
    end
    tier(2) do
      # After a reboot the running kernel's command line carries nokaslr.
      test_local_command('nokaslr present on the running kernel cmdline',
                         'cat /proc/cmdline',
                         'nokaslr')
      # With KASLR off the kernel is at its fixed default base address, so the
      # kernel text symbol is the same low address every boot.
      test_local_command('kernel loaded at the fixed (non-randomised) base',
                         'grep " _stext$" /proc/kallsyms 2>/dev/null | cut -d" " -f1',
                         'ffffffff81000000')
    end
  end
end

DisableKaslrTest.new.run
