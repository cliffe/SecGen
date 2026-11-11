require_relative '../../../../../lib/post_provision_test'

# Post-provision test for the Webmin Package Updates RCE (CVE-2022-36446,
# exploit/linux/http/webmin_package_updates_rce). The module installs Webmin
# 1.996 (the last release vulnerable to CVE-2022-36446; the fix shipped in
# 1.997), served by its own miniserv daemon over HTTPS on port 10000, and
# creates a full-privilege Webmin administrator whose credentials come from the
# webmin_username / webmin_password datastores. CVE-2022-36446 is an
# authenticated OS command injection in the Software Package Updates module
# (package-updates/update.cgi), which concatenates the chosen package names into
# a shell command. Because miniserv runs as root, exploitation gives code
# execution as root.
#
# read_fact coverage (every input is exercised or its reason to skip is noted):
#   port             -> self.port (get_port), used by tier 2.
#   webmin_username  -> tier 1 (user line present) and tier 2 (login succeeds).
#   webmin_password  -> tier 2 (the credential logs in over HTTPS, as the
#                       exploit's do_login does).
#   leaked_filenames -> tier 1/2 (the root-only flag file(s)).
#   strings_to_leak  -> tier 2 (flag file contents).
#
# Tiers:
#   1  Webmin and the vulnerable package-updates CGI are installed, and the
#      datastore admin user exists in miniserv.users.
#   2  miniserv serves HTTPS on the configured port, reports the vulnerable
#      version 1.996, and accepts the datastore credentials (302 + session).
#   3  the Metasploit module, run from the attacker VM, authenticates and injects
#      an OS command via the package-updates module to gain a root shell.
#      Deferred to the t3 pipeline (see the stub at the end of test_module).
class WebminPackageUpdatesRceTest < PostProvisionTest
  def initialize
    self.module_name = 'webmin_package_updates_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    username = (self.json_inputs['webmin_username'] || ['admin']).first
    password = (self.json_inputs['webmin_password'] || []).first
    leaked_filenames = self.json_inputs['leaked_filenames'] || []
    strings_to_leak  = self.json_inputs['strings_to_leak'] || []
    storage_dir = '/root'

    # Tier 1 — provisioned on the target.
    tier(1) do
      test_command_succeeds('webmin package installed',
                            "dpkg-query -W -f='${Status}' webmin 2>/dev/null | grep -q 'install ok installed'")
      test_command_succeeds('webmin core present', 'test -f /usr/share/webmin/version')
      # The exploited module and its vulnerable CGI.
      test_command_succeeds('package-updates module present', 'test -d /usr/share/webmin/package-updates')
      test_command_succeeds('vulnerable update.cgi present', 'test -f /usr/share/webmin/package-updates/update.cgi')
      # The datastore admin account was created (webmin_username input applied).
      test_command_succeeds("webmin admin user #{username.inspect} exists",
                            "grep -q '^#{username}:' /etc/webmin/miniserv.users")

      # Root-only flag file(s) the RCE is meant to read (leaked_filenames input).
      leaked_filenames.each do |filename|
        test_command_succeeds("leaked flag #{filename} present",
                              "test -f #{storage_dir}/#{filename}")
      end
    end

    # Tier 2 — the service works and the credential is accepted.
    tier(2) do
      test_service_up # port 10000 (or the configured port) listening

      # HTTPS answers and reports exactly the vulnerable version. The Server
      # header is MiniServ/1.996; the MSF module's AutoCheck treats >= 1.997 as
      # not a target, so pinning 1.996 is what keeps the exploit applicable.
      test_command_succeeds('miniserv serves HTTPS and reports vulnerable version 1.996',
                            "curl -sk --max-time 20 -o /dev/null -D - https://127.0.0.1:#{self.port}/ " \
                            "| grep -q 'MiniServ/1.996'")

      # The datastore credential logs in, exactly the step the exploit performs
      # before injecting (POST user/pass to /session_login.cgi, expect a 302 and
      # a session cookie). Proves webmin_username + webmin_password were applied.
      if password && !password.empty?
        login_cmd = "code=$(curl -sk --max-time 25 -b 'testing=1' " \
                    "-H 'Referer: https://127.0.0.1:#{self.port}/' " \
                    "-o /dev/null -w '%{http_code}' " \
                    "--data-urlencode 'user=#{username}' --data-urlencode 'pass=#{password}' " \
                    "https://127.0.0.1:#{self.port}/session_login.cgi); test \"$code\" = 302"
        test_command_succeeds('datastore credential logs in over HTTPS (302)', login_cmd)
      else
        skip_check('datastore credential logs in over HTTPS', 'no webmin_password input to test', tier: 2)
      end

      # Flag contents match the strings_to_leak input. leak_files pairs
      # strings_to_leak[i] with leaked_filenames[i], appending any overflow
      # strings to the first file.
      if leaked_filenames.any? && strings_to_leak.any?
        strings_to_leak.each_with_index do |string, i|
          filename = leaked_filenames[i] || leaked_filenames.first
          test_file_contains("#{storage_dir}/#{filename}", string,
                             label: "flag #{filename} contains leaked string ##{i}")
        end
      end
    end

    # Authenticated RCE over HTTPS on 10000: pass the datastore webmin creds and
    # SSL so the module can log in before triggering the package-updates injection.
tier(3) do
      test_msf_exploit('exploit/linux/http/webmin_package_updates_rce',
                       rport: self.port,
                       options: { 'USERNAME' => username, 'PASSWORD' => password, 'SSL' => true },
                       sentinel_wait: 25,
                       expect_privilege: 'root_rwx',
                       tier: 3)
    end
  end
end

WebminPackageUpdatesRceTest.new.run
