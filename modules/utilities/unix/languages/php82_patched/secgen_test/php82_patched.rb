require_relative '../../../../../lib/post_provision_test'

# Tests the php82_patched utility. It is a language runtime guarantee, not a
# service or a vulnerability, so it tops out at tier 2. The tier-2 negative
# check asserts the php2shell fix is present from the installed package version
# (design level, cites the CVEs, no exploit traffic). On Debian 8.2 the version
# string is authoritative, unlike the 7.4 source build.
#
# The module declares no read_facts, so there is nothing parameterised to assert
# and no port; test_service_up is intentionally absent.
class Php82PatchedTest < PostProvisionTest
  FIXED = '8.2.35-1~deb12u1'.freeze

  def initialize
    self.module_name = 'php82_patched'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('php8.2-common installed', 'dpkg -l php8.2-common | grep -E "^ii"', 'php8.2-common')
    end

    tier(2) do
      test_local_command('php8.2 runs', '/usr/bin/php8.2 -v', 'PHP 8.2')

      # Negative check (design level): php2shell (CVE-2026-109618 /
      # CVE-2026-109619) is closed because php8.2 is at the Debian fix
      # (DLA-4848-1). Checked from the package version, not by exploit traffic.
      ver = run_command("dpkg-query -W -f='${Version}' php8.2-common 2>/dev/null")[:stdout].to_s.strip
      patched = run_command("dpkg --compare-versions '#{ver}' ge '#{FIXED}' && echo FIXED")[:stdout].to_s.include?('FIXED')
      if patched
        pass_check('php2shell fix present (CVE-2026-109618/109619)',
                   "php8.2-common #{ver} >= #{FIXED} (DLA-4848-1)", tier: 2)
      else
        fail_check('php2shell fix present (CVE-2026-109618/109619)',
                   "php8.2-common #{ver.inspect} < fixed #{FIXED}", tier: 2)
      end
    end
  end
end

Php82PatchedTest.new.run
