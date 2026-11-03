require_relative '../../../../../lib/post_provision_test'

class ApacheDruidRceTest < PostProvisionTest
  def initialize
    self.module_name = 'apache_druid_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # read_facts: port (self.port, tiers 2/3), unix_username (tier 1 + exploit
    # shell owner), leaked_filenames + strings_to_leak (tier 1 flag check below).
    username  = self.json_inputs['unix_username']&.first
    flag_file = self.json_inputs['leaked_filenames']&.first
    flag_str  = self.json_inputs['strings_to_leak']&.first

    tier(1) do
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
      # Druid is extracted from a tarball to /usr/local/apache-druid (manifests/install.pp)
      test_local_command('druid install exists', 'test -d /usr/local/apache-druid && echo present', 'present')
      # The flag (strings_to_leak) is leaked into leaked_filenames under the
      # druid user's home (manifests/configure.pp -> leak_files).
      if username && flag_file && flag_str
        test_local_command('leaked flag present', "cat /home/#{username}/#{flag_file}", flag_str)
      end
    end
    tier(2) do
      test_service_up
      # /status returns {"version":"..."} when the coordinator is up
      test_http('/status', match: 'version')
    end
    # Tier 3: CVE-2021-25646 — the JS RCE (MSF apache_druid_js_rce) runs our
    # sentinel command on the target. The module's default target 0 "Linux
    # (dropper)" is ARCH_X86/X64 (CmdStager), so the default cmd/unix/generic is
    # rejected as incompatible; target 1 "Unix (in-memory)" is ARCH_CMD and runs
    # the command directly via the JS exec, with no staging/LHOST. The shell
    # lands as the druid service user (non-root, non-sudoer) -> <privilege>=user_rwx.
    collect = username ? "cat /home/#{username}/#{flag_file || '*'}" : nil
    test_msf_exploit('exploit/linux/http/apache_druid_js_rce',
                     rport: self.port,
                     payload: 'cmd/unix/generic',
                     options: { 'TARGET' => 1 },
                     collect: collect,
                     expect_privilege: 'user_rwx',
                     tier: 3)
  end
end

ApacheDruidRceTest.new.run
