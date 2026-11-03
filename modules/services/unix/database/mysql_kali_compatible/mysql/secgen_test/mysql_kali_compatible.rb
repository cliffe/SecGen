require_relative '../../../../../lib/post_provision_test'

class MysqlKaliCompatibleTest < PostProvisionTest
  # The metadata declares no read_fact or default_input, so there are no inputs
  # to check; the port is the fixed MariaDB port.
  def initialize
    self.module_name = 'mysql_kali_compatible'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('mysqld installed?', 'which mysqld || dpkg -l mysql-server | grep -E "^ii"', 'mysql')
      # the module creates the mysql user and its log directory
      test_local_command('mysql user exists', 'id mysql', 'uid=')
      test_local_command('/var/log/mysql owned by mysql', 'stat -c %U /var/log/mysql', 'mysql')
      # override_options turn SSL off
      test_local_command('ssl disabled in config', 'grep -rE "skip-ssl" /etc/mysql/', 'skip-ssl')
      test_local_command('mariadb enabled at boot', 'systemctl is-enabled mariadb', 'enabled')
    end
    tier(2) do
      # MariaDB 11.x runs as /usr/sbin/mariadbd (mysqld is only a symlink to it)
      test_local_command('mysqld running?', 'pgrep -a -x "mariadbd|mysqld"', '/usr/sbin/m')
      test_service_up(port: 3306)
      # the server answers a query over the local socket
      test_local_command('server answers a query', 'mysql -N -e "select 1"', '1')
    end
  end
end

MysqlKaliCompatibleTest.new.run
