require_relative '../../../../../lib/post_provision_test'

class AdoreRootkitStaticTest < PostProvisionTest
  # hidden_ports / hidden_strings are commented out in the metadata and the
  # Puppet (TODO: install Adore with configuration), so there are no inputs to check.
  def initialize
    self.module_name = 'adore_rootkit_static'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # bundled binaries, installed root:root 0755
      %w[ls_a netstat_a ps_a].each do |bin|
        test_local_command("#{bin} installed", "test -f /bin/#{bin} && echo /bin/#{bin}", "/bin/#{bin}")
        test_local_command("#{bin} is root:root 0755", "stat -c '%a %U:%G' /bin/#{bin}", '755 root:root')
        test_command_succeeds("#{bin} is non-empty", "test -s /bin/#{bin}", tier: 1)
      end
    end
    tier(2) do
      test_command_succeeds('ls_a executable', '/bin/ls_a --help || /bin/ls_a /')
      test_command_succeeds('ps_a executable', '/bin/ps_a aux >/dev/null')
      # each binary actually runs and produces real output
      test_local_command('ls_a lists a directory', '/bin/ls_a /bin', 'bash')
      test_local_command('ps_a lists processes', '/bin/ps_a aux 2>&1', 'PID')
      test_command_succeeds('netstat_a lists sockets', '/bin/netstat_a -an >/dev/null 2>&1')
    end
  end
end

AdoreRootkitStaticTest.new.run
