require_relative '../../../../../lib/post_provision_test'

class KaliTop10Test < PostProvisionTest
  # Packages install.pp installs: kali-tools-top10 itself is not installed (see the Puppet comment)
  PACKAGES = %w[nfs-common tnftp burpsuite john metasploit-framework nmap responder sqlmap wireshark].freeze

  def initialize
    self.module_name = 'kali_top10'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs packages.
  def test_module
    super
    tier(1) do
      PACKAGES.each { |pkg| test_local_command("#{pkg} installed", "dpkg -l #{pkg} | grep -E \"^ii\"", pkg) }
    end
    tier(2) do
      test_command_succeeds('nmap runs', 'nmap --version')
      # run the tools as an unprivileged user, so PATH and shared-library problems show up
      test_command_succeeds('nmap runs as an unprivileged user', with_temp_home('nmap --version'), user: 'nobody')
      test_command_succeeds('sqlmap runs as an unprivileged user', with_temp_home('sqlmap --version'), user: 'nobody')
      test_command_succeeds('editcap (wireshark) runs as an unprivileged user', with_temp_home('editcap --version'), user: 'nobody')
      test_local_command('john prints its usage', with_temp_home('john 2>&1'), 'John the Ripper', user: 'nobody')
      test_local_command('tnftp prints its usage', with_temp_home('tnftp -? 2>&1 | tr A-Z a-z'), 'usage', user: 'nobody')
      test_command_succeeds('showmount (nfs-common) runs', with_temp_home('/usr/sbin/showmount --version'), user: 'nobody')
      # responder needs root to do anything useful, so run its help as root
      test_local_command('responder prints its help', 'responder --help 2>&1', 'Responder')
      # burpsuite is a GUI/Java app with no cheap CLI call: the package and its launcher are checked in tier 1/here
      test_command_succeeds('burpsuite launcher is executable', with_temp_home('test -x "$(command -v burpsuite)"'), user: 'nobody')
    end
  end

  # nobody's home is /nonexistent, and john, wpscan and wfuzz write to $HOME on start,
  # so give each run a throwaway home
  def with_temp_home(cmd)
    "h=$(mktemp -d); HOME=$h #{cmd}; rc=$?; rm -rf \"$h\"; exit $rc"
  end
end

KaliTop10Test.new.run
