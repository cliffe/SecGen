require 'spec_helper_acceptance'
require 'puppet/util/package'
require_relative '../mysql_helper.rb'

describe 'mysql_grant' do
  before(:all) do
    pp = <<-MANIFEST
      class { 'mysql::server':
        root_password => 'password',
      }
    MANIFEST

    execute_manifest(pp, catch_failures: true)
  end

  describe 'missing privileges for user' do
    pp = <<-MANIFEST
        mysql_user { 'test1@tester':
          ensure => present,
        }
        mysql_grant { 'test1@tester/test.*':
          ensure  => 'present',
          table   => 'test.*',
          user    => 'test1@tester',
          require => Mysql_user['test1@tester'],
        }
    MANIFEST
    it 'fails' do
      expect(execute_manifest(pp, expect_failures: true).stderr).to match(%r{`privileges` `parameter` is required})
    end

    it 'does not find the user' do
      expect(shell('mysql -NBe "SHOW GRANTS FOR test1@tester"', acceptable_exit_codes: 1).stderr).to match(%r{There is no such grant defined for user 'test1' on host 'tester'})
    end
  end

  describe 'missing table for user' do
    pp = <<-MANIFEST
        mysql_user { 'atest@tester':
          ensure => present,
        }
        mysql_grant { 'atest@tester/test.*':
          ensure     => 'present',
          user       => 'atest@tester',
          privileges => ['ALL'],
          require    => Mysql_user['atest@tester'],
        }
    MANIFEST
    it 'fails' do
      execute_manifest(pp, expect_failures: true)
    end

    it 'does not find the user' do
      expect(shell('mysql -NBe "SHOW GRANTS FOR atest@tester"', acceptable_exit_codes: 1).stderr).to match(%r{There is no such grant defined for user 'atest' on host 'tester'})
    end
  end

  describe 'adding privileges' do
    pp = <<-MANIFEST
        mysql_user { 'test2@tester':
          ensure => present,
        }
        mysql_grant { 'test2@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test2@tester',
          privileges => ['SELECT', 'UPDATE'],
          require    => Mysql_user['test2@tester'],
        }
    MANIFEST
    it 'works without errors' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      shell('mysql -NBe "SHOW GRANTS FOR test2@tester"') do |r|
        expect(r.stdout).to match(%r{GRANT SELECT, UPDATE.*TO 'test2'@'tester'})
      end
    end
    it 'finds the user #stderr' do
      shell('mysql -NBe "SHOW GRANTS FOR test2@tester"') do |r|
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding privileges with special character in name' do
    pp = <<-MANIFEST
        mysql_user { 'test-2@tester':
          ensure => present,
        }
        mysql_grant { 'test-2@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test-2@tester',
          privileges => ['SELECT', 'UPDATE'],
          require    => Mysql_user['test-2@tester'],
        }
    MANIFEST
    it 'works without errors' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test-2'@tester\"") do |r|
        expect(r.stdout).to match(%r{GRANT SELECT, UPDATE.*TO 'test-2'@'tester'})
      end
    end
    it 'finds the user #stderr' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test-2'@tester\"") do |r|
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding option' do
    pp = <<-MANIFEST
        mysql_user { 'test3@tester':
          ensure => present,
        }
        mysql_grant { 'test3@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test3@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE'],
          require    => Mysql_user['test3@tester'],
        }
    MANIFEST
    it 'works without errors' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      shell('mysql -NBe "SHOW GRANTS FOR test3@tester"') do |r|
        expect(r.stdout).to match(%r{GRANT SELECT, UPDATE ON `test`.* TO 'test3'@'tester' WITH GRANT OPTION$})
      end
    end
    it 'finds the user #stderr' do
      shell('mysql -NBe "SHOW GRANTS FOR test3@tester"') do |r|
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding all privileges without table' do
    pp = <<-MANIFEST
        mysql_user { 'test4@tester':
          ensure => present,
        }
        mysql_grant { 'test4@tester/test.*':
          ensure     => 'present',
          user       => 'test4@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
          require    => Mysql_user['test4@tester'],
        }
    MANIFEST
    it 'fails' do
      expect(execute_manifest(pp, expect_failures: true).stderr).to match(%r{`table` `parameter` is required.})
    end
  end

  describe 'adding all privileges' do
    pp = <<-MANIFEST
        mysql_user { 'test4@tester':
          ensure => present,
        }
        mysql_grant { 'test4@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test4@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
          require    => Mysql_user['test4@tester'],
        }
    MANIFEST
    it 'onlies try to apply ALL' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      shell('mysql -NBe "SHOW GRANTS FOR test4@tester"') do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test4'@'tester' WITH GRANT OPTION})
      end
    end
    it 'finds the user #stderr' do
      shell('mysql -NBe "SHOW GRANTS FOR test4@tester"') do |r|
        expect(r.stderr).to be_empty
      end
    end
  end

  # Test combinations of user@host to ensure all cases work.
  describe 'short hostname' do
    pp = <<-MANIFEST
        mysql_user { 'test@short':
          ensure => present,
        }
        mysql_grant { 'test@short/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@short',
          privileges => 'ALL',
          require    => Mysql_user['test@short'],
        }
        mysql_user { 'test@long.hostname.com':
          ensure => present,
        }
        mysql_grant { 'test@long.hostname.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@long.hostname.com',
          privileges => 'ALL',
          require    => Mysql_user['test@long.hostname.com'],
        }
        mysql_user { 'test@192.168.5.6':
          ensure => present,
        }
        mysql_grant { 'test@192.168.5.6/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@192.168.5.6',
          privileges => 'ALL',
          require    => Mysql_user['test@192.168.5.6'],
        }
        mysql_user { 'test@2607:f0d0:1002:0051:0000:0000:0000:0004':
          ensure => present,
        }
        mysql_grant { 'test@2607:f0d0:1002:0051:0000:0000:0000:0004/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@2607:f0d0:1002:0051:0000:0000:0000:0004',
          privileges => 'ALL',
          require    => Mysql_user['test@2607:f0d0:1002:0051:0000:0000:0000:0004'],
        }
        mysql_user { 'test@::1/128':
          ensure => present,
        }
        mysql_grant { 'test@::1/128/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@::1/128',
          privileges => 'ALL',
          require    => Mysql_user['test@::1/128'],
        }
    MANIFEST
    it 'applies' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'finds short hostname #stdout' do
      shell('mysql -NBe "SHOW GRANTS FOR test@short"') do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'short'})
      end
    end
    it 'finds short hostname #stderr' do
      shell('mysql -NBe "SHOW GRANTS FOR test@short"') do |r|
        expect(r.stderr).to be_empty
      end
    end

    it 'finds long hostname #stdout' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'long.hostname.com'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'long.hostname.com'})
      end
    end
    it 'finds long hostname #stderr' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'long.hostname.com'\"") do |r|
        expect(r.stderr).to be_empty
      end
    end

    it 'finds ipv4 #stdout' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.6'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'192.168.5.6'})
      end
    end
    it 'finds ipv4 #stderr' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.6'\"") do |r|
        expect(r.stderr).to be_empty
      end
    end

    it 'finds ipv6 #stdout' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'2607:f0d0:1002:0051:0000:0000:0000:0004'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'2607:f0d0:1002:0051:0000:0000:0000:0004'})
      end
    end
    it 'finds ipv6 #stderr' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'2607:f0d0:1002:0051:0000:0000:0000:0004'\"") do |r|
        expect(r.stderr).to be_empty
      end
    end

    it 'finds short ipv6 #stdout' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'::1/128'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'::1\/128'})
      end
    end
    it 'finds short ipv6 @stderr' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'::1/128'\"") do |r|
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'complex test' do
    pp = <<-MANIFEST
        $dbSubnet = '10.10.10.%'

        mysql_database { 'foo':
          ensure => present,
        }

        exec { 'mysql-create-table':
          command     => '/usr/bin/mysql -NBe "CREATE TABLE foo.bar (name VARCHAR(20))"',
          environment => "HOME=${::root_home}",
          unless      => '/usr/bin/mysql -NBe "SELECT 1 FROM foo.bar LIMIT 1;"',
          require     => Mysql_database['foo'],
        }

        Mysql_grant {
          ensure     => present,
          options    => ['GRANT'],
          privileges => ['ALL'],
          table      => '*.*',
          require    => [ Mysql_database['foo'], Exec['mysql-create-table'] ],
        }

        mysql_user { "user1@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "user1@${dbSubnet}/*.*":
          user       => "user1@${dbSubnet}",
          require    => Mysql_user["user1@${dbSubnet}"],
        }
        mysql_user { "user2@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "user2@${dbSubnet}/foo.bar":
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          user       => "user2@${dbSubnet}",
          table      => 'foo.bar',
          require    => Mysql_user["user2@${dbSubnet}"],
        }
        mysql_user { "user3@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "user3@${dbSubnet}/foo.*":
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          user       => "user3@${dbSubnet}",
          table      => 'foo.*',
          require    => Mysql_user["user3@${dbSubnet}"],
        }
        mysql_user { 'web@%':
          ensure => present,
        }
        mysql_grant { 'web@%/*.*':
          user       => 'web@%',
          require    => Mysql_user['web@%'],
        }
        mysql_user { "web@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "web@${dbSubnet}/*.*":
          user       => "web@${dbSubnet}",
          require    => Mysql_user["web@${dbSubnet}"],
        }
        mysql_user { "web@${fqdn}":
          ensure => present,
        }
        mysql_grant { "web@${fqdn}/*.*":
          user       => "web@${fqdn}",
          require    => Mysql_user["web@${fqdn}"],
        }
        mysql_user { 'web@localhost':
          ensure => present,
        }
        mysql_grant { 'web@localhost/*.*':
          user       => 'web@localhost',
          require    => Mysql_user['web@localhost'],
        }
    MANIFEST
    it 'setup mysql::server' do
      execute_manifest(pp, catch_failures: true)
      execute_manifest(pp, catch_changes: true)
    end
  end

  describe 'lower case privileges' do
    pp_one = <<-MANIFEST
        mysql_user { 'lowercase@localhost':
          ensure => present,
        }
        mysql_grant { 'lowercase@localhost/*.*':
          user       => 'lowercase@localhost',
          privileges => 'ALL',
          table      => '*.*',
          require    => Mysql_user['lowercase@localhost'],
        }
    MANIFEST
    it 'create ALL privs' do
      execute_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'lowercase@localhost':
          ensure => present,
        }
        mysql_grant { 'lowercase@localhost/*.*':
          user       => 'lowercase@localhost',
          privileges => 'all',
          table      => '*.*',
          require    => Mysql_user['lowercase@localhost'],
        }
    MANIFEST
    it 'create lowercase all privs' do
      expect(execute_manifest(pp_two, catch_failures: true).exit_code).to eq(0)
    end
  end

  describe 'adding procedure privileges' do
    pp = <<-MANIFEST
        exec { 'simpleproc-create':
          command => 'mysql --user="root" --password="password" --database=mysql --delimiter="//" -NBe "CREATE PROCEDURE simpleproc (OUT param1 INT) BEGIN SELECT COUNT(*) INTO param1 FROM t; end//"',
          path    => '/usr/bin/',
          before  => Mysql_user['test2@tester'],
        }
        mysql_user { 'test2@tester':
          ensure => present,
        }
        mysql_grant { 'test2@tester/PROCEDURE mysql.simpleproc':
          ensure     => 'present',
          table      => 'PROCEDURE mysql.simpleproc',
          user       => 'test2@tester',
          privileges => ['EXECUTE'],
          require    => Mysql_user['test2@tester'],
        }
    MANIFEST
    it 'works without errors' do
      execute_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      shell('mysql -NBe "SHOW GRANTS FOR test2@tester"') do |r|
        expect(r.stdout).to match(%r{GRANT EXECUTE ON PROCEDURE `mysql`.`simpleproc` TO 'test2'@'tester'})
      end
    end
    it 'finds the user #stderr' do
      shell('mysql -NBe "SHOW GRANTS FOR test2@tester"') do |r|
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding function privileges' do
    it 'works without errors' do
      pp = <<-EOS
        exec { 'simplefunc-create':
          command => '/usr/bin/mysql --user="root" --password="password" --database=mysql -NBe "CREATE FUNCTION simplefunc (s CHAR(20)) RETURNS CHAR(50) DETERMINISTIC RETURN CONCAT(\\'Hello, \\', s, \\'!\\')"',
          before  => Mysql_user['test3@tester'],
        }

        mysql_user { 'test3@tester':
          ensure => 'present',
        }

        mysql_grant { 'test3@tester/FUNCTION mysql.simplefunc':
          ensure     => 'present',
          table      => 'FUNCTION mysql.simplefunc',
          user       => 'test3@tester',
          privileges => ['EXECUTE'],
          require    => Mysql_user['test3@tester'],
        }
      EOS

      execute_manifest(pp, catch_failures: true)
    end
    # rubocop:enable RSpec/ExampleLength
    it 'finds the user' do
      shell('mysql -NBe "SHOW GRANTS FOR test3@tester"') do |r|
        expect(r.stdout).to match(%r{GRANT EXECUTE ON FUNCTION `mysql`.`simplefunc` TO 'test3'@'tester'})
        expect(r.stderr).to be_empty
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'proxy privilieges' do
    pre_run

    describe 'adding proxy privileges', if: version_is_greater_than('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy1@tester':
          ensure => present,
        }
        mysql_grant { 'proxy1@tester/proxy_user@proxy_host':
          ensure     => 'present',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy1@tester',
          privileges => ['PROXY'],
          require    => Mysql_user['proxy1@tester'],
        }
      MANIFEST
      it 'works without errors when version greater than 5.5.0' do
        execute_manifest(pp, catch_failures: true)
      end

      it 'finds the user #stdout' do
        shell('mysql -NBe "SHOW GRANTS FOR proxy1@tester"') do |r|
          expect(r.stdout).to match(%r{GRANT PROXY ON 'proxy_user'@'proxy_host' TO 'proxy1'@'tester'})
        end
      end
      it 'finds the user #stderr' do
        shell('mysql -NBe "SHOW GRANTS FOR proxy1@tester"') do |r|
          expect(r.stderr).to be_empty
        end
      end
    end

    describe 'removing proxy privileges', if: version_is_greater_than('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy1@tester':
          ensure => present,
        }
        mysql_grant { 'proxy1@tester/proxy_user@proxy_host':
          ensure     => 'absent',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy1@tester',
          privileges => ['PROXY'],
          require    => Mysql_user['proxy1@tester'],
        }
      MANIFEST
      it 'works without errors' do
        execute_manifest(pp, catch_failures: true)
      end

      it 'finds the user #stdout' do
        shell('mysql -NBe "SHOW GRANTS FOR proxy1@tester"') do |r|
          expect(r.stdout).not_to match(%r{GRANT PROXY ON 'proxy_user'@'proxy_host' TO 'proxy1'@'tester'})
        end
      end
      it 'finds the user #stderr' do
        shell('mysql -NBe "SHOW GRANTS FOR proxy1@tester"') do |r|
          expect(r.stderr).to be_empty
        end
      end
    end

    describe 'adding proxy privileges with other privileges', if: version_is_greater_than('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy2@tester':
          ensure => present,
        }
        mysql_grant { 'proxy2@tester/proxy_user@proxy_host':
          ensure     => 'present',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy2@tester',
          privileges => ['PROXY', 'SELECT'],
          require    => Mysql_user['proxy2@tester'],
        }
      MANIFEST
      it 'fails' do
        expect(execute_manifest(pp, expect_failures: true).stderr).to match(%r{`privileges` `parameter`: PROXY can only be specified by itself})
      end

      it 'does not find the user' do
        expect(shell('mysql -NBe "SHOW GRANTS FOR proxy2@tester"', acceptable_exit_codes: 1).stderr).to match(%r{There is no such grant defined for user 'proxy2' on host 'tester'})
      end
    end

    describe 'adding proxy privileges with mysql version less than 5.5.0', unless: version_is_greater_than('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy3@tester':
          ensure => present,
        }
        mysql_grant { 'proxy3@tester/proxy_user@proxy_host':
          ensure     => 'present',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy3@tester',
          privileges => ['PROXY', 'SELECT'],
          require    => Mysql_user['proxy3@tester'],
        }
      MANIFEST
      it 'fails' do
        expect(execute_manifest(pp, expect_failures: true).stderr).to match(%r{PROXY user not supported on mysql versions < 5\.5\.0}i)
      end

      it 'does not find the user' do
        expect(shell('mysql -NBe "SHOW GRANTS FOR proxy2@tester"', acceptable_exit_codes: 1).stderr).to match(%r{There is no such grant defined for user 'proxy2' on host 'tester'})
      end
    end

    describe 'adding proxy privileges with invalid proxy user', if: version_is_greater_than('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy3@tester':
          ensure => present,
        }
        mysql_grant { 'proxy3@tester/invalid_proxy_user':
          ensure     => 'present',
          table      => 'invalid_proxy_user',
          user       => 'proxy3@tester',
          privileges => ['PROXY'],
          require    => Mysql_user['proxy3@tester'],
        }
      MANIFEST
      it 'fails' do
        expect(execute_manifest(pp, expect_failures: true).stderr).to match(%r{`table` `property` for PROXY should be specified as proxy_user@proxy_host.})
      end

      it 'does not find the user' do
        expect(shell('mysql -NBe "SHOW GRANTS FOR proxy3@tester"', acceptable_exit_codes: 1).stderr).to match(%r{There is no such grant defined for user 'proxy3' on host 'tester'})
      end
    end
  end

  describe 'grants with skip-name-resolve specified' do
    pp_one = <<-MANIFEST
        class { 'mysql::server':
          override_options => {
            'mysqld' => {'skip-name-resolve' => true}
          },
          restart          => true,
        }
    MANIFEST
    it 'setup mysql::server' do
      execute_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'test@fqdn.com':
          ensure => present,
        }
        mysql_grant { 'test@fqdn.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@fqdn.com',
          privileges => 'ALL',
          require    => Mysql_user['test@fqdn.com'],
        }
        mysql_user { 'test@192.168.5.7':
          ensure => present,
        }
        mysql_grant { 'test@192.168.5.7/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@192.168.5.7',
          privileges => 'ALL',
          require    => Mysql_user['test@192.168.5.7'],
        }
    MANIFEST
    it 'applies' do
      execute_manifest(pp_two, catch_failures: true)
    end

    it 'fails with fqdn' do
      pre_run
      unless version_is_greater_than('5.7.0')
        expect(shell('mysql -NBe "SHOW GRANTS FOR test@fqdn.com"', acceptable_exit_codes: 1).stderr).to match(%r{There is no such grant defined for user 'test' on host 'fqdn.com'})
      end
    end

    it 'finds ipv4 #stdout' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.7'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'192.168.5.7'})
      end
    end
    it 'finds ipv4 #stderr' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.7'\"") do |r|
        expect(r.stderr).to be_empty
      end
    end

    pp_three = <<-MANIFEST
        mysql_user { 'test@fqdn.com':
          ensure => present,
        }
        mysql_grant { 'test@fqdn.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@fqdn.com',
          privileges => 'ALL',
          require    => Mysql_user['test@fqdn.com'],
        }
    MANIFEST
    it 'fails to execute while applying' do
      mysql_cmd = shell('which mysql').stdout.chomp
      shell("mv #{mysql_cmd} #{mysql_cmd}.bak")
      expect(execute_manifest(pp_three, expect_failures: true).stderr).to match(%r{Could not find a suitable provider for mysql_grant})
      shell("mv #{mysql_cmd}.bak #{mysql_cmd}")
    end

    pp_four = <<-MANIFEST
        class { 'mysql::server':
          restart          => true,
        }
    MANIFEST
    it 'reset mysql::server config' do
      execute_manifest(pp_four, catch_failures: true)
    end
  end

  describe 'adding privileges to specific table' do
    # Using puppet_apply as a helper
    pp_one = <<-MANIFEST
        class { 'mysql::server': override_options => { 'root_password' => 'password' } }
    MANIFEST
    it 'setup mysql server' do
      execute_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'test@localhost':
          ensure => present,
        }
        mysql_grant { 'test@localhost/grant_spec_db.grant_spec_table':
          user       => 'test@localhost',
          privileges => ['SELECT'],
          table      => 'grant_spec_db.grant_spec_table',
          require    => Mysql_user['test@localhost'],
        }
    MANIFEST
    it 'creates grant on missing table will fail' do
      expect(execute_manifest(pp_two, expect_failures: true).stderr).to match(%r{Table 'grant_spec_db\.grant_spec_table' doesn't exist})
    end

    pp_three = <<-MANIFEST
        file { '/tmp/grant_spec_table.sql':
          ensure  => file,
          content => 'CREATE TABLE grant_spec_table (id int);',
          before  => Mysql::Db['grant_spec_db'],
        }
        mysql::db { 'grant_spec_db':
          user     => 'root1',
          password => 'password',
          sql      => '/tmp/grant_spec_table.sql',
        }
    MANIFEST
    it 'creates table' do
      execute_manifest(pp_three, catch_failures: true)
    end

    it 'has the table' do
      expect(shell("mysql -e 'show tables;' grant_spec_db|grep grant_spec_table").exit_code).to be_zero
    end
  end
end
