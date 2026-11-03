require_relative '../../../../../lib/post_provision_test'

class RaspapRceTest < PostProvisionTest
  def initialize
    self.module_name = 'raspap_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('lighttpd installed?', 'dpkg -l lighttpd | grep -E "^ii"', 'lighttpd')
      test_local_command('raspap installed?', 'test -d /var/www/raspap && echo present', 'present')
      test_local_command('vulnerable CVE-2022-39986 endpoint present',
                         'test -f /var/www/raspap/ajax/openvpn/del_ovpncfg.php && echo present', 'present')
    end

    # leaked_filenames/strings_to_leak: flag, dropped into $storage_directory (/var/www, see
    # raspap_rce::config). secgen_functions::leak_files pairs strings_to_leak[i] with
    # leaked_filenames[i], appending extra strings to the first filename once filenames run out.
    leaked_filenames = self.json_inputs['leaked_filenames'] || []
    strings_to_leak = self.json_inputs['strings_to_leak'] || []
    storage_dir = '/var/www'
    if leaked_filenames.any?
      tier(1) do
        leaked_filenames.each do |filename|
          test_local_command("leaked file #{filename} present", "test -f #{storage_dir}/#{filename} && echo ok", 'ok')
        end
      end
      tier(2) do
        strings_to_leak.each_with_index do |string, i|
          filename = leaked_filenames[i] || leaked_filenames.first
          test_local_command("#{filename} contains leaked string ##{i}", "cat #{storage_dir}/#{filename}", string)
        end
      end
    end

    # admin_password: raspap_rce::config bcrypt-hashes this into config/raspap.auth via
    # htpasswd. RASPI_AUTH_ENABLED is deliberately false (CVE-2022-39986 is unauthenticated),
    # so the password gates no login flow to observe over HTTP - instead verify the stored
    # hash actually matches the configured password, proving the module applied the input
    # rather than leaving a stale/default hash.
    if (admin_password = self.json_inputs['admin_password']&.first)
      tier(1) do
        test_local_command('raspap.auth holds username and bcrypt hash',
                           'cat /var/www/raspap/config/raspap.auth', 'admin')
        # htpasswd -vb exits 0 when the password matches the stored hash and
        # non-zero otherwise; it prints its verdict ('Password for user admin
        # correct.') to stderr, whose exact wording we must not depend on. Gate
        # a sentinel on the exit code and match that instead.
        verify_cmd = "awk 'NR==2' /var/www/raspap/config/raspap.auth > /tmp/raspap_hash_check && " \
                     "printf 'admin:%s\\n' \"$(cat /tmp/raspap_hash_check)\" > /tmp/raspap_auth_check && " \
                     "htpasswd -vb /tmp/raspap_auth_check admin '#{admin_password}' >/dev/null 2>&1 && echo HASH_OK; " \
                     "rm -f /tmp/raspap_hash_check /tmp/raspap_auth_check"
        test_local_command('admin_password matches stored bcrypt hash', verify_cmd, 'HASH_OK')
      end
    end

    tier(2) do
      test_service_up
      test_http('/', match: 'RaspAP')
      # the unauthenticated vulnerable endpoint answers (auth disabled for the CVE)
      test_http('/ajax/openvpn/del_ovpncfg.php', status: 200)

      # Negative check (design level): the php2shell vector (CVE-2026-109618 /
      # CVE-2026-109619) is closed because php8.2 carries the Debian fix
      # (DLA-4848-1, 8.2.35-1~deb12u1). Verified from the installed package
      # version, not by sending exploit traffic. Leaves the app's own
      # CVE-2022-39986 (tested at tier 3) as the only working exploit.
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
    test_msf_exploit('exploit/unix/http/raspap_rce',
                     rport: self.port,
                     expect_privilege: 'user_rwx',
                     tier: 3)
  end
end

RaspapRceTest.new.run
