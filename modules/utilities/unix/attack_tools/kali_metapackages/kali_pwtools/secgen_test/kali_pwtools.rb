require_relative '../../../../../lib/post_provision_test'

class KaliPwtoolsTest < PostProvisionTest
  def initialize
    self.module_name = 'kali_pwtools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # No inputs. The module only installs the kali-tools-passwords metapackage.
    tier(1) do
      test_local_command('kali-tools-passwords installed', 'dpkg -l kali-tools-passwords | grep -E "^ii"', 'kali-tools-passwords')
      %w[john hashcat hydra crunch].each do |tool|
        test_local_command("#{tool} on PATH", "which #{tool}", tool)
      end
    end
    tier(2) do
      test_command_succeeds('john available', 'john --list=formats')
      test_command_succeeds('hashcat runs', 'hashcat --version')
      test_local_command('hydra runs', 'hydra -h 2>&1', 'Hydra')
      test_local_command('crunch generates a wordlist', 'crunch 1 1 a 2>/dev/null', 'a')
    end
  end
end

KaliPwtoolsTest.new.run
