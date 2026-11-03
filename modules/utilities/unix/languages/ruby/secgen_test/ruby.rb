require_relative '../../../../../lib/post_provision_test'

class RubyTest < PostProvisionTest
  def initialize
    self.module_name = 'ruby'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No read_facts or default inputs: nothing to parameterise.
  def test_module
    super
    tier(1) do
      test_local_command('ruby on PATH?', 'which ruby', 'ruby')
      test_local_command('ruby package installed?', 'dpkg -l ruby | grep -E "^ii"', 'ruby')
      test_local_command('gem on PATH?', 'which gem', 'gem')
    end
    tier(2) do
      test_command_succeeds('ruby version', 'ruby --version')
      test_local_command('ruby runs code as an unprivileged user', 'ruby -e "puts 6*7"', '42', user: 'nobody')
      test_local_command('ruby standard library loads', 'ruby -rjson -e "puts JSON.generate([1])"', '[1]', user: 'nobody')
      test_command_succeeds('gem runs', 'gem --version', user: 'nobody')
    end
  end
end

RubyTest.new.run
