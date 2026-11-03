require_relative '../../../../../lib/post_provision_test'

# Verifies that before_login_message wrote its messages to /etc/issue and /etc/issue.net.
# The messages are scenario-controlled (strings_to_leak); each non-empty one must be in both files.
class BeforeLoginMessageTest < PostProvisionTest
  def initialize
    self.module_name = 'before_login_message'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    messages = (self.json_inputs['strings_to_leak'] || []).reject { |m| m.to_s.strip.empty? }
    tier(1) do
      test_command_succeeds('/etc/issue exists', 'test -f /etc/issue')
      test_command_succeeds('/etc/issue.net exists', 'test -f /etc/issue.net')
    end
    tier(2) do
      if messages.any?
        messages.each do |msg|
          test_local_command('/etc/issue contains message', 'cat /etc/issue', msg)
          test_local_command('/etc/issue.net contains message', 'cat /etc/issue.net', msg)
        end
      else
        test_local_command('/etc/issue has content', 'test -s /etc/issue && echo ok', 'ok')
        test_local_command('/etc/issue.net has content', 'test -s /etc/issue.net && echo ok', 'ok')
      end
    end
  end
end

BeforeLoginMessageTest.new.run
