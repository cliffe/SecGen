require_relative '../../../../../lib/post_provision_test'

class WiresharkTest < PostProvisionTest
  def initialize
    self.module_name = 'wireshark'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('wireshark installed?', 'dpkg -l wireshark | grep -E "^ii"', 'wireshark')
      test_local_command('tcpdump installed?', 'which tcpdump', 'tcpdump')
    end
    tier(2) do
      test_command_succeeds('tshark version runs', 'tshark --version')
      test_command_succeeds('tcpdump version runs', 'tcpdump --version')
    end
  end
end

WiresharkTest.new.run
