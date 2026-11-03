require_relative '../../../../../lib/post_provision_test'

class GlpiPhpInjectionTest < PostProvisionTest
  def initialize
    self.module_name = 'glpi_php_injection'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # GLPI requires apache and mysql (declared in <requires>); check both are present
      test_local_command('apache2 installed?', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('glpi installed?', 'test -d /var/www/html/glpi && echo present', 'present')
      test_local_command('php installed?', 'php --version', 'PHP')
    end
    tier(2) do
      test_service_up
      # GLPI login page returns a form with "GLPI" branding
      test_http('/', match: 'GLPI')
      # Tier-3 precondition: the bundled htmLawed test page (the CVE-2022-35914
      # sink) must be directly reachable under the vhost docroot and render its
      # CSRF token field. This is exactly the GET the MSF module's
      # populate_values makes before injecting via hhook=exec/text; if it fails,
      # the exploit can't retrieve its token/sid ("Failed to retrieve htmLawed
      # page"), so pin it down at tier 2.
      test_http('/vendor/htmlawed/htmlawed/htmLawedTest.php', match: 'id="token"',
                label: 'htmLawed test page reachable (tier-3 precondition)')

      # Negative check (design level): the php2shell vector (CVE-2026-109618 /
      # CVE-2026-109619) is closed because php8.2 carries the Debian fix
      # (DLA-4848-1, 8.2.35-1~deb12u1). Verified from the installed package
      # version, not by sending exploit traffic. The app's own CVE-2022-35914
      # is the intended exploit (tier 3 below).
      fixed = '8.2.35-1~deb12u1'
      ver = run_command("dpkg-query -W -f='${Version}' php8.2-common 2>/dev/null")[:stdout].to_s.strip
      patched = run_command("dpkg --compare-versions '#{ver}' ge '#{fixed}' && echo FIXED")[:stdout].to_s.include?('FIXED')
      if patched
        pass_check('php2shell fix present (CVE-2026-109618/109619)',
                   "php8.2-common #{ver} >= #{fixed} (DLA-4848-1)", tier: 2)
      else
        fail_check('php2shell fix present (CVE-2026-109618/109619)',
                   "php8.2-common #{ver.inspect} < fixed #{fixed}", tier: 2)
      end
    end
    # Real MSF module source (modules/exploits/linux/http/
    # glpi_htmlawed_php_injection.rb): default target is "Nix Command"
    # (Arch_CMD, Type :unix_cmd), which calls execute_command(payload.encoded)
    # directly — the base-class default cmd/unix/generic payload (CMD run
    # verbatim via the htmLawed sink) is correct here.  An earlier attempt
    # used payload: 'php/unix/cmd/generic' (assuming PHP-platform like
    # gravcms_exec) — that payload path doesn't exist and MSF rejects it.
    # TARGET_URI stays '/' since the vhost docroot is the glpi/ dir itself
    # (see apache.pp).
    # Apache's PrivateTmp=true gives each worker its own /tmp namespace, so a
    # sentinel written there is invisible to the root guest-agent read. Use
    # /dev/shm instead — it is shared across all processes and namespaces.
    test_msf_exploit('exploit/linux/http/glpi_htmlawed_php_injection',
                     rport: self.port,
                     expect_privilege: 'user_rwx',
                     force: true,
                     sentinel_dir: '/dev/shm',
                     options: { 'TARGET_URI' => '/' },
                     tier: 3)
  end
end

GlpiPhpInjectionTest.new.run
