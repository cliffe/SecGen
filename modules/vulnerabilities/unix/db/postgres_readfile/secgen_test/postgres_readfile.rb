require 'shellwords'
require_relative '../../../../../lib/post_provision_test'

class PostgresReadfileTest < PostProvisionTest
  # The PostgreSQL port is fixed by the required postgresql service module
  # (5432, its default); this module declares no port read_fact, so the port is
  # referenced directly here.
  POSTGRES_PORT = 5432
  CONF_DIR = '/etc/postgresql/15/main'.freeze

  def initialize
    self.module_name = 'postgres_readfile'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Resolved inputs — the test must hold for any parameterised deployment.
    username  = self.json_inputs['username']&.first
    password  = self.json_inputs['password']&.first
    database  = self.json_inputs['database_name']&.first
    method    = self.json_inputs['auth_method']&.first
    storage   = self.json_inputs['storage_directory']&.first
    filename  = (self.json_inputs['leaked_filenames'] || []).first
    flag_text = (self.json_inputs['strings_to_leak'] || []).first
    flag_path = (storage && filename) ? "#{storage}/#{filename}" : nil

    tier(1) do
      test_local_command('postgresql server installed', 'dpkg -l postgresql-15 | grep -E "^ii"', 'postgresql-15')
      test_local_command('psql client installed', 'which psql', 'psql')
      # The cluster is exposed on every interface (the service module binds '*'
      # from the shared listen_addresses input), which makes the role reachable.
      test_local_command('cluster exposed on all interfaces',
                         "grep -E \"^listen_addresses\\s*=\\s*'\\*'\" #{CONF_DIR}/conf.d/secgen.conf",
                         'listen_addresses')
      # The remote pg_hba rule was appended for the role.
      if database && username && method
        test_local_command('pg_hba.conf remote rule for the role',
                           "grep -E '^host\\s+#{database}\\s+#{username}\\s+0\\.0\\.0\\.0/0\\s+#{method}\\s*$' #{CONF_DIR}/pg_hba.conf",
                           username)
      end
      if username
        # pg_read_server_files membership is what makes the file read possible.
        test_local_command("role #{username} has pg_read_server_files",
                           "runuser -u postgres -- psql -tAc " \
                           "\"SELECT pg_has_role('#{username}','pg_read_server_files','USAGE')\"",
                           't')
      end
      if flag_path
        test_local_command('flag planted and server-readable',
                           "test -r #{Shellwords.escape(flag_path)} && echo present", 'present')
      end
    end

    tier(2) do
      test_service_up(port: POSTGRES_PORT)
      test_local_command('cluster accepts connections', "pg_isready -p #{POSTGRES_PORT}", 'accepting connections')
      # listen_addresses '*' binds every interface, so the role is reachable off-box.
      test_local_command('listens on all interfaces',
                         "ss -ltn | grep -E '(0\\.0\\.0\\.0|\\*):#{POSTGRES_PORT}\\s'", ":#{POSTGRES_PORT}")

      if username && password && database
        psql = "PGPASSWORD=#{Shellwords.escape(password)} psql -h 127.0.0.1 -p #{POSTGRES_PORT} " \
               "-U #{Shellwords.escape(username)} -d #{Shellwords.escape(database)} -tA"
        test_local_command('remote role authenticates over the network',
                           "#{psql} -c 'select current_database()'", database)

        if flag_path && flag_text
          # The role reads an arbitrary server file via COPY ... FROM — proves the
          # pg_read_server_files grant end-to-end over TCP, without an attacker VM.
          copy = "#{psql} -c \"CREATE TEMP TABLE sg(l text); COPY sg FROM '#{flag_path}'; " \
                 "SELECT string_agg(l, E'\\n') FROM sg\""
          test_local_command('COPY reads the planted flag', copy, flag_text)
        end
      end
    end

    # Tier 3: prove the file read from the attacker VM with the stock MSF
    # auxiliary. It gives no shell (privilege is info_leak), so test_msf_exploit
    # doesn't apply — run_msf_module drives it and the caller asserts on output.
    # postgres_readfile COPYs RFILE into a temp table and prints its contents, so
    # a genuine read echoes the unique planted flag string back in the output.
    tier(3) do
      next unless username && password && database && flag_path && flag_text

      aux = run_msf_module('auxiliary/admin/postgres/postgres_readfile',
                           options: { 'USERNAME' => username, 'PASSWORD' => password,
                                      'DATABASE' => database, 'RFILE' => flag_path,
                                      'RPORT' => POSTGRES_PORT, 'VERBOSE' => false },
                           label: 'postgres readfile')
      next unless aux

      if aux[:msf_output].to_s.include?(flag_text)
        pass_check('postgres_readfile discloses the planted file',
                   "File read confirmed: postgres_readfile on #{aux[:attacker]} read #{flag_path} " \
                   "through pg_read_server_files on #{aux[:rhost]}:#{POSTGRES_PORT} and returned the planted flag",
                   tier: 3)
      else
        fail_check('postgres_readfile discloses the planted file',
                   'postgres_readfile did not return the planted flag. ' \
                   'See msf_output_postgres_readfile evidence.',
                   tier: 3)
      end
    end

    # Inputs all checked above: username, password, database_name, auth_method,
    # storage_directory, leaked_filenames and strings_to_leak each drive an assertion.
  end
end

PostgresReadfileTest.new.run
