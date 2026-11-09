require 'shellwords'
require_relative '../../../../../lib/post_provision_test'

class PostgresqlTest < PostProvisionTest
  def initialize
    self.module_name = 'postgresql'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Every read_fact is checked: port, database_name, username, password,
  # listen_addresses and auth_method. The password is a throwaway generated one,
  # passed to psql through PGPASSWORD (not argv) on the guest only.
  def test_module
    super
    port      = self.json_inputs['port']&.first
    db        = self.json_inputs['database_name']&.first
    user      = self.json_inputs['username']&.first
    password  = self.json_inputs['password']&.first
    listen    = self.json_inputs['listen_addresses']&.first
    method    = self.json_inputs['auth_method']&.first

    tier(1) do
      test_local_command('postgresql server installed', 'dpkg -l postgresql-15 | grep -E "^ii"', 'postgresql-15')
      test_local_command('psql client installed', 'which psql', 'psql')
      test_local_command('postgresql enabled at boot', 'systemctl is-enabled postgresql', 'enabled')
      test_local_command('configured port', 'grep -E "^port" /etc/postgresql/15/main/conf.d/secgen.conf', port.to_s) if port
      test_local_command('configured listen_addresses', 'grep -E "^listen_addresses" /etc/postgresql/15/main/conf.d/secgen.conf', listen.to_s) if listen
      if db && user && method
        test_local_command('pg_hba.conf line for the role',
                           "grep -E '^host\\s+#{db}\\s+#{user}\\s+127\\.0\\.0\\.1/32\\s+#{method}\\s*$' /etc/postgresql/15/main/pg_hba.conf",
                           method)
      end
    end

    tier(2) do
      test_service_up
      test_local_command('cluster accepts connections', "pg_isready -p #{port}", 'accepting connections') if port

      # listen_addresses: 'localhost' stays on loopback, '*' binds every interface
      if listen && port
        if listen == 'localhost'
          test_local_command('listens on loopback only',
                             "ss -ltn | grep -E ':#{port}\\s' | grep -vE '(0\\.0\\.0\\.0|\\*|\\[::\\]):#{port}\\s'",
                             "127.0.0.1:#{port}")
        elsif listen == '*'
          test_local_command('listens on all interfaces', "ss -ltn | grep -E '(0\\.0\\.0\\.0|\\*):#{port}\\s'", ":#{port}")
        end
      end

      if port && db && user && password
        psql = "PGPASSWORD=#{Shellwords.escape(password)} psql -h 127.0.0.1 -p #{port} -U #{Shellwords.escape(user)} -d #{Shellwords.escape(db)} -tA"
        test_local_command('configured credential is accepted', "#{psql} -c 'select current_database()'", db)
        test_local_command('role owns the database',
                           "#{psql} -c 'select pg_catalog.pg_get_userbyid(datdba) from pg_database where datname = current_database()'",
                           user)
        # a wrong password must be refused, unless the method is 'trust'
        unless method == 'trust'
          bad = "PGPASSWORD=wrong-#{Shellwords.escape(password)} psql -h 127.0.0.1 -p #{port} -U #{Shellwords.escape(user)} -d #{Shellwords.escape(db)} -tA -c 'select 1' >/dev/null 2>&1; echo \"rc=$?\""
          test_local_command('wrong password is refused', bad, 'rc=2')
        end
      end
    end
  end
end

PostgresqlTest.new.run
