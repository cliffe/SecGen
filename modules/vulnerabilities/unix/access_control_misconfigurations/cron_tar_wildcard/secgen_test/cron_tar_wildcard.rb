require_relative '../../../../../lib/post_provision_test'

class CronTarWildcardTest < PostProvisionTest
  def initialize
    self.module_name = 'cron_tar_wildcard'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    test_local_command('backup directory exists and is world-writable?', 'sudo ls -la /opt/backup', 'backup')
    test_local_command('hint file is readable?', 'sudo cat /opt/backup.txt', 'tar')
    test_local_command('cron job exists?', 'sudo crontab -l', 'backup_wildcard')
  end
end

CronTarWildcardTest.new.run
