require_relative '../../../../../lib/post_provision_test'

class MySQLTest < PostProvisionTest
  # The metadata declares no read_fact or default_input, so there are no inputs
  # to check; the port is the fixed MySQL port.
  def initialize
    self.module_name = 'mysql'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # mysql::server and mysql::client are both installed
      test_local_command('mysql client installed?', 'which mysql', 'mysql')
      test_local_command('mysql server package installed?', 'dpkg -l | grep -E "^ii\s+(mysql|mariadb)-server"', 'server')
      # override_options disable SSL. 'ssl-disable' is a Puppet-side switch that
      # my.cnf.erb never writes out; the option MariaDB reads is skip-ssl.
      test_local_command('ssl disabled in config', 'grep -rE "^skip-ssl" /etc/mysql/', 'skip-ssl')
    end
    tier(2) do
      # Debian 12 installs MariaDB with a mariadbd binary; Debian 10 installs
      # MariaDB 10.3, whose binary is still mysqld
      test_local_command('mysqld process running?', 'ps -eo args | grep -E "^/usr/sbin/(mariadbd|mysqld)"', '/usr/sbin/')
      test_service_up(port: 3306)
      if module_on_system?('security_shepherd')
        # Security Shepherd gives root a password (grant.sql), so a passwordless
        # root query is refused by design. mysqladmin ping exits 0 whenever the
        # server answers, even when it refuses the login (it then prints the
        # access-denied error instead of "mysqld is alive"), and 1 when nothing
        # answers. Shepherd's own test runs a real query with its credentials.
        test_local_command('server answers (mysqladmin ping)',
                           'mysqladmin ping >/dev/null 2>&1; echo "ping_rc=$?"', 'ping_rc=0')
      else
        # the server answers a query over the local socket
        test_local_command('server answers a query', 'mysql -N -e "select 1"', '1')
      end
    end
  end
end

MySQLTest.new.run
