require_relative '../../../../../lib/post_provision_test'

# Tests the patched PHP 7.4 utility. It is a language runtime, not a service or
# a vulnerability, so it tops out at tier 2 (present, runs). The tier-2 block
# also carries a negative check that the php2shell vector is closed: this is a
# design-level provenance assertion (the interpreter was built from the pinned
# upstream fix commit), not an exploit attempt, and does not rely on the version
# string, which reads 7.4.31-dev whether or not the fix is present.
#
# The module declares no read_facts, so there is nothing parameterised to assert
# from json_inputs and no port; test_service_up is intentionally absent.
class Php7PatchedTest < PostProvisionTest
  PREFIX    = '/opt/php-7.4-patched'.freeze
  PHP_BIN   = "#{PREFIX}/bin/php".freeze
  MARKER    = "#{PREFIX}/PHP2SHELL_FIX_COMMIT".freeze
  # The commit the build is pinned to; must match the module's install.pp.
  FIX_COMMIT = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'.freeze

  def initialize
    self.module_name = 'php7_patched'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('patched php binary present',
                         "test -x #{PHP_BIN} && echo present", 'present')
      test_local_command('php2shell provenance marker present',
                         "cat #{MARKER}", FIX_COMMIT)
    end

    tier(2) do
      # The interpreter loads and reports the 7.4 branch.
      test_local_command('patched php runs and is 7.4', "#{PHP_BIN} -v", 'PHP 7.4')
      # update-alternatives made the patched build the default `php`.
      test_local_command('default php is the patched build',
                         'readlink -f "$(command -v php)"', PHP_BIN)
      # php-fpm is up for an Apache/lighttpd app to reach over FastCGI.
      test_local_command('php-fpm listening on 127.0.0.1:9000', 'ss -ltn', ':9000')

      # Negative check (design level): the php2shell vector
      # (CVE-2026-109618 / CVE-2026-109619) is closed because the interpreter
      # was built from the upstream fix commit. Proven by build provenance, not
      # by sending exploit traffic and not by version string.
      marker = run_command("cat #{MARKER}")[:stdout].to_s.strip
      if marker == FIX_COMMIT
        pass_check('php2shell fix present (CVE-2026-109618/109619)',
                   "built from php-src fix commit #{FIX_COMMIT}", tier: 2)
      else
        fail_check('php2shell fix present (CVE-2026-109618/109619)',
                   "provenance marker #{marker.inspect} does not match " \
                   "pinned fix commit #{FIX_COMMIT}", tier: 2)
      end
    end
  end
end

Php7PatchedTest.new.run
