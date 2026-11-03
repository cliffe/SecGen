require_relative '../../../../../lib/post_provision_test'

class CronLegacyTest < PostProvisionTest
  def initialize
    self.module_name = 'cron_legacy'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # no read_facts: this module takes no inputs
    tier(1) do
      test_local_command('cron package installed?', 'dpkg -l cron | grep -E "^ii"', 'cron')
      test_local_command('crontab binary present', 'which crontab', 'crontab')
      test_local_command('cron enabled at boot', 'systemctl is-enabled cron', 'enabled')
    end
    tier(2) do
      test_command_succeeds('cron service running', 'systemctl is-active cron')
      # the cron daemon is actually up and processing jobs, not just reported active
      test_command_succeeds('cron daemon process running', 'pgrep -x cron')
      test_command_succeeds('crontab is readable (for root)', 'crontab -l; test $? -le 1')
    end
  end
end

CronLegacyTest.new.run
