require_relative '../../../../../lib/post_provision_test'

# No <read_fact>s on this module (it just installs a fixed vulnerable bash
# build), so there is nothing in json_inputs to parameterise the checks on.
class ShellshockTest < PostProvisionTest
  def initialize
    self.module_name = 'shellshock'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('vulnerable bash installed', '/bin/bash --version', 'version 4.1') }
    tier(2) do
      # CVE-2014-6271: a function definition left in an exported environment
      # variable runs any trailing command when a new bash parses it. Proves
      # the installed build is actually vulnerable, without exploiting it.
      test_local_command(
        'shellshock payload executes from environment',
        %q{env x='() { :;}; echo SHELLSHOCK_VULNERABLE' /bin/bash -c 'echo test'},
        'SHELLSHOCK_VULNERABLE'
      )
    end
  end
end

ShellshockTest.new.run
