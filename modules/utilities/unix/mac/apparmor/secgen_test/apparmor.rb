require_relative '../../../../../lib/post_provision_test'

class ApparmorTest < PostProvisionTest
  def initialize
    self.module_name = 'apparmor'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # chroot_dir is commented out of the module's metadata, so there is no input to check.
    tier(1) do
      test_local_command('apparmor installed?', 'dpkg -l apparmor | grep -E "^ii"', 'apparmor')
      %w[apparmor-notify apparmor-profiles apparmor-profiles-extra apparmor-utils auditd].each do |pkg|
        test_local_command("#{pkg} installed", "dpkg -l #{pkg} | grep -E '^ii'", pkg)
      end
      # apparmor-easyprof is a virtual package on Debian 12 (provided by apparmor-utils),
      # so dpkg never lists it; check that an installed package provides it
      test_local_command('apparmor-easyprof provided',
                         "dpkg-query -W -f='${db:Status-Abbrev} ${Package} provides: ${Provides}\\n' | grep -E '^ii .*apparmor-easyprof'",
                         'apparmor-easyprof')
      test_command_succeeds('aa-easyprof on the PATH', 'command -v aa-easyprof', tier: 1)
      # the default pidgin profile is removed (it breaks the pidgin module)
      test_command_succeeds('pidgin profile removed', 'test ! -e /etc/apparmor.d/usr.bin.pidgin')
      # AppArmor is switched on in the kernel command line defaults
      test_local_command('grub enables apparmor', 'cat /etc/default/grub.d/apparmor.cfg', 'apparmor=1 security=apparmor')
      test_command_succeeds('dovecot local override stubs created', 'test -e /etc/apparmor.d/local/usr.sbin.dovecot')
    end
    tier(2) do
      test_command_succeeds('apparmor service active', 'systemctl is-active apparmor')
      test_local_command('aa-status reports profiles', 'aa-status 2>&1 | grep -i "profile"', 'profile')
      test_command_succeeds('aa-status runs', 'aa-status')
      test_local_command('apparmor enabled in the kernel', 'cat /sys/module/apparmor/parameters/enabled', 'Y')
      test_local_command('aa-enabled reports yes', 'aa-enabled', 'Yes')
      # easyprof works: it generates a profile that the parser accepts (-Q: parse only, don't load)
      test_command_succeeds('aa-easyprof generates a valid profile',
                            'set -o pipefail; aa-easyprof /usr/bin/true | apparmor_parser -Q -K')
    end
  end
end

ApparmorTest.new.run
