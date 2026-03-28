require_relative '../../../../../lib/post_provision_test'

class CronWritableScriptTest < PostProvisionTest
  def initialize
    self.module_name = 'cron_writable_script'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    test_local_command('cron.sh is world-writable?', 'sudo ls -la /opt/cron.sh', 'rwxrwxrwx')
    test_local_command('cron job exists?', 'sudo crontab -l', 'writable_cron_script')
  end
end

CronWritableScriptTest.new.run
