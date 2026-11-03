require_relative '../../../../../lib/post_provision_test'

# Verifies that after_login_message appended a message to /etc/bash.bashrc.
# The messages are scenario-controlled (strings_to_leak); each non-empty one must be in the file
# and printed when an interactive shell starts.
class AfterLoginMessageTest < PostProvisionTest
  def initialize
    self.module_name = 'after_login_message'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    messages = (self.json_inputs['strings_to_leak'] || []).reject { |m| m.to_s.strip.empty? }
    tier(1) do
      test_command_succeeds('/etc/bash.bashrc exists', 'test -f /etc/bash.bashrc')
    end
    tier(2) do
      if messages.any?
        messages.each do |msg|
          test_local_command('bash.bashrc contains message', 'cat /etc/bash.bashrc', msg)
        end
        # an interactive shell sources bash.bashrc, so the message is printed (output or stderr)
        messages.each do |msg|
          test_local_command('interactive shell prints message',
                             'bash --rcfile /etc/bash.bashrc -i -c true </dev/null 2>&1', msg)
        end
      else
        # The block is "cat <<'EOF'", the (empty) message, then a terminator line. A bare grep -c EOF
        # counts the opener too (2), so anchor on the terminator line to get exactly 1.
        test_local_command('bash.bashrc has heredoc block', 'grep -c "^EOF$" /etc/bash.bashrc', '1')
      end
    end
  end
end

AfterLoginMessageTest.new.run
