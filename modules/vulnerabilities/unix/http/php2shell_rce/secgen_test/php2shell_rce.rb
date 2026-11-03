require_relative '../../../../../lib/post_provision_test'

# Post-provision test for the php2shell practice target. The exploit itself is
# left to the student, so there is no tier-3 exploit check here. Instead tier 2
# confirms the box is the intended vulnerable control: the page serves on the
# unpatched PHP, and the php2shell-vulnerable code is what is installed
# (CVE-2026-109618 / CVE-2026-109619) — proven from build provenance and the
# absence of the fix's symbol in the on-box source, not by exploiting anything.
# The version string cannot tell vulnerable from patched (both are 7.4.31-dev).
class Php2shellRceTest < PostProvisionTest
  PHP_BIN     = '/opt/php-7.4-vulnerable/bin/php'.freeze
  MARKER      = '/opt/php-7.4-vulnerable/PHP2SHELL_VULN_COMMIT'.freeze
  VULN_COMMIT = '004cb827501d1ddaf98daacb185a53e0816f78a7'.freeze
  FIX_COMMIT  = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'.freeze
  SRC_DIR     = "/opt/php-src-#{VULN_COMMIT}".freeze
  FIX_SYMBOL  = 'zend_new_array_singleton'.freeze
  DOCROOT     = '/var/www/html'.freeze

  def initialize
    self.module_name = 'php2shell_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('vulnerable php present', "test -x #{PHP_BIN} && echo present", 'present')
      test_local_command('target page present', "test -f #{DOCROOT}/index.php && echo present", 'present')
    end

    # flag: leaked to /root (see php2shell_rce::install). leak_files pairs
    # strings_to_leak[i] with leaked_filenames[i].
    leaked_filenames = self.json_inputs['leaked_filenames'] || []
    strings_to_leak  = self.json_inputs['strings_to_leak'] || []
    if leaked_filenames.any?
      tier(1) do
        leaked_filenames.each do |fn|
          test_local_command("flag file #{fn} present", "test -f /root/#{fn} && echo ok", 'ok')
        end
      end
      tier(2) do
        strings_to_leak.each_with_index do |s, i|
          fn = leaked_filenames[i] || leaked_filenames.first
          test_local_command("flag #{fn} contains leaked string ##{i}", "cat /root/#{fn}", s)
        end
      end
    end

    tier(2) do
      test_service_up
      # Prove the page answers over HTTP via the guest-agent path (curl on the
      # box). test_http's own HTTP client is unreliable against this php-cgi
      # setup, while a guest-side curl reflects what a visitor gets.
      test_local_command('target page served over HTTP',
                         "curl -s http://127.0.0.1:#{self.port}/", 'php2shell practice target')

      # Confirm the php2shell-vulnerable code is what's on the box: built from
      # the pre-fix commit and the fix's symbol absent from the source. No exploit.
      # src_present guards against a false pass: if SRC_DIR is missing, grep
      # returns a non-zero exit and fix_found is false, which would satisfy
      # !fix_found even though no source was ever there to inspect.
      marker      = run_command("cat #{MARKER}")[:stdout].to_s.strip
      src_present = run_command("test -d #{SRC_DIR}/Zend && echo ok")[:stdout].to_s.include?('ok')
      fix_found   = src_present && run_command("grep -rqs #{FIX_SYMBOL} #{SRC_DIR}/Zend && echo FOUND")[:stdout].to_s.include?('FOUND')
      if marker == VULN_COMMIT && marker != FIX_COMMIT && src_present && !fix_found
        pass_check('php2shell vulnerable code present (CVE-2026-109618/109619)',
                   "pre-fix commit #{VULN_COMMIT}; fix symbol #{FIX_SYMBOL} absent from source", tier: 2)
      else
        fail_check('php2shell vulnerable code present (CVE-2026-109618/109619)',
                   "marker=#{marker.inspect} (want #{VULN_COMMIT}); src_present=#{src_present}; fix symbol found=#{fix_found}", tier: 2)
      end
    end

    # No tier 3: exploiting php2shell is the student's exercise; this module
    # ships a known-vulnerable target, not a packaged exploit.
  end
end

Php2shellRceTest.new.run
