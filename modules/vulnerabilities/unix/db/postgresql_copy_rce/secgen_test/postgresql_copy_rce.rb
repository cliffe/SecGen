require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class PostgresqlCopyRceTest < PostProvisionTest
  def initialize
    self.module_name = 'postgresql_copy_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # read_facts: username, password, auth_method — all three are observable on the
  # box and checked below. This module adds no port input of its own; the
  # required postgresql service defaults to 5432, so the port is hardcoded like
  # the mysql vuln tests hardcode 3306.
  def test_module
    super
    user   = self.json_inputs['username']&.first    || 'postgres'
    pass   = self.json_inputs['password']&.first     || 'postgres'
    method = self.json_inputs['auth_method']&.first  || 'scram-sha-256'
    port   = 5432
    conf   = '/etc/postgresql/15/main/conf.d/zz_secgen_copy_rce.conf'
    hba    = '/etc/postgresql/15/main/pg_hba.conf'

    tier(1) do
      test_local_command('postgresql server installed', 'dpkg -l postgresql-15 | grep -E "^ii"', 'postgresql-15')
      test_local_command('cluster opened to the network', "grep -E '^listen_addresses' #{conf}", "'*'")
      test_local_command('pg_hba allows the superuser from any host',
                         "grep -E '^host\\s+all\\s+#{Regexp.escape(user)}\\s+0\\.0\\.0\\.0/0\\s+#{Regexp.escape(method)}' #{hba}",
                         user)
      test_local_command('role exists and is a superuser',
                         "runuser -u postgres -- psql -tAc \"select rolsuper from pg_roles where rolname = '#{user}'\"",
                         't')
    end

    tier(2) do
      # listen_addresses '*' binds every interface, so the cluster is reachable
      # off loopback (how the attacker VM reaches it at tier 3).
      test_local_command('cluster listening on all interfaces', 'ss -ltn', "0.0.0.0:#{port}")

      psql = "PGPASSWORD=#{Shellwords.escape(pass)} psql -h 127.0.0.1 -p #{port} -U #{Shellwords.escape(user)} -d template1 -tA"
      test_local_command('weak superuser credential accepted over TCP',
                         "#{psql} -c 'select current_user'", user)
      test_local_command('authenticated role has superuser rights',
                         "#{psql} -c 'select usesuper from pg_user where usename = current_user'", 't')

      # A wrong password must be refused (psql exits 2), unless auth is 'trust'.
      unless method == 'trust'
        bad = "PGPASSWORD=wrong-#{Shellwords.escape(pass)} psql -h 127.0.0.1 -p #{port} -U #{Shellwords.escape(user)} -d template1 -tA -c 'select 1' >/dev/null 2>&1; echo \"rc=$?\""
        test_local_command('wrong password is refused', bad, 'rc=2')
      end
    end

    # This module has no port input, so self.port is -1; the required postgresql
    # service listens on 5432 (hardcoded like the mysql vuln tests use 3306). The
    # superuser credential is generated (weak), so it never matches the module's
    # default postgres/postgres — pass USERNAME/PASSWORD so MSF can authenticate.
    test_msf_exploit('exploit/multi/postgres/postgres_copy_from_program_cmd_exec',
                     rport: port,
                     options: { 'USERNAME' => user, 'PASSWORD' => pass, 'DATABASE' => 'template1' },
                     expect_privilege: 'user_rwx',
                     tier: 3)
  end
end

PostgresqlCopyRceTest.new.run
