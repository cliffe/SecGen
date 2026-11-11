require_relative '../../../../../lib/post_provision_test'

# Service module: tops out at tier 2 (it installed, and it serves). The
# exploitable behaviour is proved by the vulnerability module that requires it
# (log4shell_header_injection), not here.
class MinimalLog4jWebappTest < PostProvisionTest
  def initialize
    self.module_name = 'minimal_log4j_webapp'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # read_facts: port (self.port, tier 2), unix_username (tier 1 + service owner).
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
      test_local_command('app compiled', 'test -f /opt/minimal_log4j_webapp/classes/com/secgen/App.class && echo present', 'present')
      test_local_command('log4j 2.14.1 jar present', 'ls /opt/minimal_log4j_webapp/lib', 'log4j-core-2.14.1.jar')
    end

    tier(2) do
      test_service_up
      test_http('/', match: 'minimal log4j webapp')
    end
  end
end

MinimalLog4jWebappTest.new.run
