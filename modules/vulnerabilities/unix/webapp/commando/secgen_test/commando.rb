require_relative '../../../../../lib/post_provision_test'

class CommandoTest < PostProvisionTest
  def initialize
    self.module_name = 'commando'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('apache2 installed', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('commando docroot exists', 'test -d /var/www/commando && echo ok', 'ok')
    end
    tier(2) do
      test_service_up
      test_http('/', port: self.port)
    end
    # TODO tier 3 (exploit): deferred — wire up test_msf_exploit when attacker VM is available
  end
end

CommandoTest.new.run
