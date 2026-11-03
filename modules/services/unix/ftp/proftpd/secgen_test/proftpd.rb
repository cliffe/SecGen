require_relative '../../../../../lib/post_provision_test'

class ProftpdTest < PostProvisionTest
  def initialize
    self.module_name = 'proftpd'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: port is the only one, checked in the config and on the wire.
  # The accounts the module requires are provided by another module.
  def test_module
    super
    port = self.json_inputs['port']&.first

    tier(1) do
      test_local_command('proftpd installed', 'dpkg -l proftpd-core proftpd-basic proftpd 2>/dev/null | grep -E "^ii"', 'proftpd')
      test_local_command('proftpd binary present', 'which proftpd', 'proftpd')
      # the module writes proftpd.conf from its template with the configured port
      test_local_command('proftpd.conf Port', 'grep -E "^Port" /etc/proftpd/proftpd.conf', port) if port
      test_local_command('proftpd runs standalone', 'grep -E "^ServerType" /etc/proftpd/proftpd.conf', 'standalone')
      test_local_command('proftpd enabled at boot', 'systemctl is-enabled proftpd', 'enabled')
    end

    tier(2) do
      test_service_up
      test_banner('220 ', label: 'FTP greeting')
      test_banner('ProFTPD', label: 'ProFTPD identifies itself')
      # the daemon answers a command, not just the greeting
      test_banner('211', send: 'FEAT', label: 'FEAT reply')
    end
  end
end

ProftpdTest.new.run
