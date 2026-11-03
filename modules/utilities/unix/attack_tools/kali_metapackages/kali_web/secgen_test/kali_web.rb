require_relative '../../../../../lib/post_provision_test'

class KaliWebTest < PostProvisionTest
  # Every package install.pp installs (kali-tools-web itself is not installed; see the Puppet comment).
  # maltego is dropped for now: re-add it here with install.pp's TODO.
  PACKAGES = %w[apache-users apache2 beef-xss burpsuite cadaver commix cutycapt default-mysql-server dirb dirbuster
                hamster-sidejack heartleech httprint httrack hydra jboss-autopwn joomscan jsql-injection
                medusa mitmproxy ncrack nikto nmap oscanner owasp-mantra-ff padbuster paros patator php php-mysql
                proxychains4 proxytunnel qsslcaudit redsocks sidguesser siege skipfish slowhttptest sqldict
                sqlitebrowser sqlmap sqlninja sqlsus ssldump sslh sslscan sslsniff sslsplit sslyze stunnel4
                thc-ssl-dos tlssled tnscmd10g uniscan wafw00f wapiti watobo webacoo webscarab weevely wfuzz whatweb
                wireshark wpscan xsser zaproxy].freeze

  def initialize
    self.module_name = 'kali_web'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs packages.
  def test_module
    super
    tier(1) do
      # one round trip for all packages; lists any that are not installed
      list = PACKAGES.join(' ')
      cmd = "for p in #{list}; do dpkg-query -W -f='${db:Status-Abbrev}' $p 2>/dev/null | grep -q '^ii' || echo \"MISSING:$p\"; done; echo CHECKED"
      out = run_command(cmd)[:stdout].to_s
      missing = out.scan(/MISSING:(\S+)/).flatten
      if out.include?('CHECKED') && missing.empty?
        pass_check("all #{PACKAGES.size} packages installed")
      else
        fail_check("all #{PACKAGES.size} packages installed", "missing: #{missing.join(', ')}")
      end
      # kali-tools-web is not installed directly; check representative packages
      test_local_command('nikto installed', 'dpkg -l nikto | grep -E "^ii"', 'nikto')
      test_local_command('sqlmap installed', 'dpkg -l sqlmap | grep -E "^ii"', 'sqlmap')
      test_local_command('wpscan installed', 'dpkg -l wpscan | grep -E "^ii"', 'wpscan')
    end
    tier(2) do
      test_command_succeeds('nikto runs', 'nikto -Version')
      # run representative tools as an unprivileged user, so PATH and shared-library problems show up
      {
        'nmap' => 'nmap --version', 'nikto' => 'nikto -Version', 'sqlmap' => 'sqlmap --version',
        'whatweb' => 'whatweb --version', 'wfuzz' => 'wfuzz --version', 'wpscan' => 'wpscan --version',
        'sslscan' => 'sslscan --version', 'editcap (wireshark)' => 'editcap --version', 'php' => 'php -v',
        'apache2' => '/usr/sbin/apache2 -v', 'mysql client' => 'mysql --version'
      }.each { |tool, cmd| test_command_succeeds("#{tool} runs as an unprivileged user", with_temp_home(cmd), user: 'nobody') }
    end
  end

  # nobody's home is /nonexistent, and john, wpscan and wfuzz write to $HOME on start,
  # so give each run a throwaway home
  def with_temp_home(cmd)
    "h=$(mktemp -d); HOME=$h #{cmd}; rc=$?; rm -rf \"$h\"; exit $rc"
  end
end

KaliWebTest.new.run
