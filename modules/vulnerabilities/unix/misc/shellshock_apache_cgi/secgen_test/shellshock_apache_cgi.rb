require_relative '../../../../../lib/post_provision_test'

class ShellshockApacheCgiTest < PostProvisionTest
  def initialize
    self.module_name = 'shellshock_apache_cgi'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # Requires: vulnerabilities/unix/bash/shellshock (vulnerable bash) + services/unix/http/apache_bash_cgi
      test_local_command('vulnerable bash present', 'bash --version', 'GNU bash')
      test_local_command('CGI script deployed', 'test -f /usr/lib/cgi-bin/test.cgi && echo present', 'present')
      test_local_command('apache CGI module enabled', 'apache2ctl -M 2>/dev/null | grep cgi', 'cgi')
    end
    tier(2) do
      test_service_up(port: 80)
      # CGI endpoint reachable — Shellshock exploits this via User-Agent / Referer headers
      test_http('/cgi-bin/test.cgi', match: 'GNU bash')
    end
    # TODO tier 3 (exploit): deferred — exploit/multi/http/apache_mod_cgi_bash_env_exec from attacker VM
    # Note: only works on Wheezy (conflicts with Stretch and Buster in metadata)
  end
end

ShellshockApacheCgiTest.new.run
