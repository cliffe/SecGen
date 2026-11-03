require_relative '../../../../../lib/post_provision_test'

class CronNewTest < PostProvisionTest
  def initialize
    self.module_name = 'cron_new'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('cron package installed?', 'dpkg -l cron | grep -E "^ii"', 'cron')
      test_local_command('crontab binary present', 'which crontab', 'crontab')
      test_local_command('cron daemon binary present', 'test -x /usr/sbin/cron && echo ok', 'ok')
      test_local_command('cron.d directory present', 'test -d /etc/cron.d && echo ok', 'ok')
    end
    tier(2) do
      test_command_succeeds('cron service running', 'systemctl is-active cron')
      # crontab -l exits 0 with a crontab, 1 with none; 127 or a crash means the tool is broken
      test_local_command('crontab runs as root',
                         'crontab -l >/dev/null 2>&1; rc=$?; [ $rc -le 1 ] && echo crontab-ok',
                         'crontab-ok')
      test_local_command('crontab runs as an unprivileged user',
                         'crontab -l >/dev/null 2>&1; rc=$?; [ $rc -le 1 ] && echo crontab-ok',
                         'crontab-ok', user: 'nobody')
    end
  end
end

CronNewTest.new.run
