require_relative '../../../../../lib/post_provision_test'

class JenkinsCliTest < PostProvisionTest
  def initialize
    self.module_name = 'jenkins_cli'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
      test_local_command('java available', 'java -version 2>&1', 'version')
    end
    tier(2) do
      test_service_up
      # Jenkins login page contains "Jenkins" in the HTML
      test_http('/login', match: 'Jenkins')
    end
    # TODO tier 3 (exploit): deferred — wire up test_msf_exploit when attacker VM is available
    # msf_module: exploit/linux/http/jenkins_cli_deserialization (CVE-2017-1000353)
  end
end

JenkinsCliTest.new.run
