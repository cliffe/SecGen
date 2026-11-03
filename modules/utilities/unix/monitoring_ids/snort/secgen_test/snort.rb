require_relative '../../../../../lib/post_provision_test'

class SnortTest < PostProvisionTest
  def initialize
    self.module_name = 'snort'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # no read_facts: the module takes no inputs
    tier(1) do
      test_local_command('snort-common installed?', 'dpkg -l snort-common | grep -E "^ii"', 'snort-common')
      test_local_command('snort-rules-default installed?', 'dpkg -l snort-rules-default | grep -E "^ii"', 'snort-rules-default')
      test_local_command('snort binary present', 'which snort', 'snort')
      test_command_succeeds('debian config present', 'test -f /etc/snort/snort.debian.conf')
      # alert_fast output is appended to snort.conf so alerts are written to a log Snort can be read from
      test_local_command('alert_fast output enabled', 'grep -F "output alert_fast" /etc/snort/snort.conf', 'output alert_fast')
      # the module deliberately disables the service: the mirrored-traffic interface may not match the box
      test_local_command('snort disabled at boot (module disables it deliberately)', 'systemctl is-enabled snort', 'disabled')
    end
    tier(2) do
      test_command_succeeds('snort version runs', 'snort --version')
      # the shipped config and rules actually parse, proving the install is usable even though the service is off
      test_command_succeeds('snort config and rules are valid', 'snort -T -c /etc/snort/snort.conf')
    end
  end
end

SnortTest.new.run
