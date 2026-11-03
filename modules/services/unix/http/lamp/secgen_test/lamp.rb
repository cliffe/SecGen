require_relative '../../../../../lib/post_provision_test'

class LampTest < PostProvisionTest
  def initialize
    self.module_name = 'lamp'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('apache2 installed?', 'dpkg -l apache2 | grep -E "^ii"', 'apache2') }
    # Debian 12 packages the database as mariadb-server; mysql-server does not exist there
    tier(1) { test_local_command('database server installed?', 'dpkg -l | grep -E "^ii\s+(mysql|mariadb)-server"', 'server') }
    tier(1) { test_local_command('php installed?', 'php --version', 'PHP') }
    tier(1) { test_local_command('mod_php installed', 'dpkg -l | grep -E "^ii\s+libapache2-mod-php"', 'libapache2-mod-php') }
    tier(1) { test_local_command('mod_php enabled, prefork MPM', 'apache2ctl -M 2>&1', 'php') }
    tier(1) { test_local_command('apache2 running', 'systemctl is-active apache2 | grep -x active', 'active') }
    tier(1) { test_local_command('mysql running', '{ systemctl is-active mysql; systemctl is-active mariadb; } | grep -x active', 'active') }
    tier(1) { test_local_command('mysql client present', 'which mysql', 'mysql') }
    tier(2) { test_service_up(port: 80) }
    tier(2) { test_http('/', port: 80) }
    tier(2) { test_service_up(port: 3306) }
    # config parses, and the database answers a real query over the root socket
    tier(2) { test_command_succeeds('apache config valid', 'apache2ctl configtest') }
    tier(2) { test_local_command('mysql answers a query', 'mysql -e "SELECT 6*7 AS answer;"', '42') }
    # Apache hands .php to the PHP module: serve a throwaway script and remove it
    tier(2) do
      test_local_command('apache executes PHP',
                         'f=/var/www/html/_secgen_lamp_probe.php; echo "<?php echo 6*7; ?>" > $f; curl -s http://127.0.0.1/_secgen_lamp_probe.php; rm -f $f',
                         '42')
    end
  end
end

LampTest.new.run
