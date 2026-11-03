require_relative '../../../../../lib/post_provision_test'

class KaliReverseEngineeringTest < PostProvisionTest
  # Tools the kali-tools-reverse-engineering metapackage is meant to provide: [binary, version command]
  TOOLS = { 'radare2' => 'radare2 -v', 'gdb' => 'gdb --version', 'nasm' => 'nasm -v' }.freeze

  def initialize
    self.module_name = 'kali_reverse_engineering'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs the metapackage.
  def test_module
    super
    tier(1) do
      test_local_command('kali-tools-reverse-engineering installed', 'dpkg -l kali-tools-reverse-engineering | grep -E "^ii"', 'kali-tools-reverse-engineering')
      TOOLS.each_key { |tool| test_local_command("#{tool} on PATH", "command -v #{tool}", "/#{tool}") }
    end
    tier(2) do
      test_command_succeeds('radare2 available', 'radare2 -v')
      # run each tool as an unprivileged user, so PATH and shared-library problems show up
      TOOLS.each { |tool, cmd| test_command_succeeds("#{tool} runs as an unprivileged user", cmd, user: 'nobody') }
    end
  end
end

KaliReverseEngineeringTest.new.run
