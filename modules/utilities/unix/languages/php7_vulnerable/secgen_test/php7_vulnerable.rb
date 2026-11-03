require_relative '../../../../../lib/post_provision_test'

# Tests the deliberately-vulnerable PHP 7.4 utility. It is a language runtime, so
# it tops out at tier 2. The tier-2 block confirms the box carries the
# php2shell-vulnerable build (CVE-2026-109618 / CVE-2026-109619): the build
# provenance is the pre-fix commit, and the php2shell fix's symbols are absent
# from the on-box source. This is a code/provenance check, not an exploit, and
# cannot use the version string (vulnerable and patched both report 7.4.31-dev).
#
# The module declares no read_facts, so there is nothing parameterised to assert
# and no port; test_service_up is intentionally absent.
class Php7VulnerableTest < PostProvisionTest
  PREFIX      = '/opt/php-7.4-vulnerable'.freeze
  PHP_BIN     = "#{PREFIX}/bin/php".freeze
  MARKER      = "#{PREFIX}/PHP2SHELL_VULN_COMMIT".freeze
  VULN_COMMIT = '004cb827501d1ddaf98daacb185a53e0816f78a7'.freeze
  FIX_COMMIT  = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'.freeze
  SRC_DIR     = "/opt/php-src-#{VULN_COMMIT}".freeze
  # A symbol the php2shell fix adds; absent from the pre-fix source.
  FIX_SYMBOL  = 'zend_new_array_singleton'.freeze

  def initialize
    self.module_name = 'php7_vulnerable'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('vulnerable php binary present',
                         "test -x #{PHP_BIN} && echo present", 'present')
      test_local_command('vulnerable provenance marker present', "cat #{MARKER}", VULN_COMMIT)
    end

    tier(2) do
      test_local_command('vulnerable php runs and is 7.4', "#{PHP_BIN} -v", 'PHP 7.4')
      test_local_command('default php is the vulnerable build',
                         'readlink -f "$(command -v php)"', PHP_BIN)

      # Confirm the php2shell-vulnerable code is what's on the box
      # (CVE-2026-109618 / CVE-2026-109619): built from the pre-fix commit, and
      # the fix's symbol is absent from the on-box source. No exploit.
      marker = run_command("cat #{MARKER}")[:stdout].to_s.strip
      # grep exits 0 if the fix symbol is found anywhere in the source tree.
      # src_present guards against a false pass: if SRC_DIR is missing, grep
      # returns a non-zero exit and fix_found is false, which would satisfy
      # !fix_found even though no source was ever there to inspect.
      src_present = run_command("test -d #{SRC_DIR}/Zend && echo ok")[:stdout].to_s.include?('ok')
      fix_found   = src_present && run_command("grep -rqs #{FIX_SYMBOL} #{SRC_DIR}/Zend && echo FOUND")[:stdout].to_s.include?('FOUND')
      if marker == VULN_COMMIT && marker != FIX_COMMIT && src_present && !fix_found
        pass_check('php2shell vulnerable code present (CVE-2026-109618/109619)',
                   "built from pre-fix commit #{VULN_COMMIT}; fix symbol #{FIX_SYMBOL} absent from source", tier: 2)
      else
        fail_check('php2shell vulnerable code present (CVE-2026-109618/109619)',
                   "marker=#{marker.inspect} (want #{VULN_COMMIT}); src_present=#{src_present}; fix symbol #{FIX_SYMBOL} found=#{fix_found}", tier: 2)
      end
    end
  end
end

Php7VulnerableTest.new.run
