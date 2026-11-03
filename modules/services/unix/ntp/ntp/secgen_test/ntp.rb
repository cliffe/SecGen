require_relative '../../../../../lib/post_provision_test'

class NTPTest < PostProvisionTest
  def initialize
    self.module_name = 'ntp'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 123 # NTP is fixed at UDP 123; the module has no inputs
  end

  def test_module
    super
    tier(1) do
      test_local_command('ntp installed?', 'dpkg -l ntp | grep -E "^ii"', 'ntp')
      test_local_command('ntpd on PATH', 'which ntpd', 'ntpd')
      test_local_command('ntpq on PATH', 'which ntpq', 'ntpq')
      # On bookworm the ntp package is transitional: ntp.service is an alias of
      # ntpsec.service, so `is-enabled ntp` prints "alias". Check the real unit.
      test_local_command('ntp service enabled', 'systemctl is-enabled ntpsec', 'enabled')
      test_local_command('ntp.conf present', 'cat /etc/ntp.conf', 'server')
    end
    tier(2) do
      test_command_succeeds('ntp service active', 'systemctl is-active ntp')
      # ntpd answers local queries and has at least one configured peer
      test_local_command('ntpd runs', 'command -v ntpd >/dev/null && ntpd --version 2>&1; true', 'ntpd')
      test_command_succeeds('ntpq answers', 'ntpq -pn')
      test_command_succeeds('ntp listening on UDP 123', 'ss -lun | grep -E ":123\b"')
      # Query from outside the guest; only possible where the host has a network path
      test_ntp_query unless proxmox?
    end
  end

  def test_ntp_query
    require 'net/ntp'
    time_response = ''
    retries = 5
    while retries > 0
      begin
        time_response = Net::NTP.get(system_ip, port).time
        break
      rescue Errno::ECONNREFUSED, Timeout::Error
        # do nothing
      end
      sleep 2
      retries = -1
    end
    if time_response != ''
      pass_check("NTP responds on UDP #{port}", "NTP responded on UDP port #{port} with #{time_response}", tier: 2)
    else
      fail_check("NTP responds on UDP #{port}", "unable to connect to #{module_name} on UDP port #{port}", tier: 2)
    end
  end
end

NTPTest.new.run
