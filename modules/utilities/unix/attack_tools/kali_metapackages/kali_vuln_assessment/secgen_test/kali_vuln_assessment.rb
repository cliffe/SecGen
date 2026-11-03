require_relative '../../../../../lib/post_provision_test'

class KaliVulnAssessmentTest < PostProvisionTest
  # Tools the kali-tools-vulnerability metapackage is meant to provide, with a command that exits 0
  TOOLS = { 'nmap' => 'nmap --version', 'nikto' => 'nikto -Version', 'lynis' => 'lynis --version',
            'sslscan' => 'sslscan --version' }.freeze

  def initialize
    self.module_name = 'kali_vuln_assessment'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs the metapackage.
  def test_module
    super
    tier(1) do
      test_local_command('kali-tools-vulnerability installed', 'dpkg -l kali-tools-vulnerability | grep -E "^ii"', 'kali-tools-vulnerability')
      TOOLS.each_key { |tool| test_local_command("#{tool} on PATH", "command -v #{tool}", "/#{tool}") }
    end
    tier(2) do
      test_command_succeeds('nmap available', 'nmap --version')
      # run each tool as an unprivileged user, so PATH and shared-library problems show up
      TOOLS.each { |tool, cmd| test_command_succeeds("#{tool} runs as an unprivileged user", cmd, user: 'nobody') }
    end
  end
end

KaliVulnAssessmentTest.new.run
