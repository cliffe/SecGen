require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class PostgresHashdumpTest < PostProvisionTest
  def initialize
    self.module_name = 'postgres_hashdump'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Both inputs are observable on the box and are checked below.
    #   username / password — the remote superuser account and its weak password.
    # The service pins PostgreSQL to the default port 5432 (the service module's own
    # port input), which is not exposed to this vulnerability module, so the port is
    # hardcoded here just as the service's own test fixes it.
    username = self.json_inputs['username']&.first || 'dbadmin'
    password = self.json_inputs['password']&.first || 'password123'
    u = Shellwords.escape(username)
    p = Shellwords.escape(password)
    psql_super = "runuser -u postgres -- psql -tAc"

    tier(1) do
      test_local_command('postgresql server installed', 'dpkg -l postgresql-15 | grep -E "^ii"', 'postgresql-15')
      # listen_addresses opened to every interface by the drop-in.
      test_local_command('listen_addresses opened to all interfaces',
                         'grep -E "^listen_addresses" /etc/postgresql/15/main/conf.d/zz_secgen_remote.conf', "'*'")
      # The remote superuser account exists and is a superuser.
      test_local_command('remote superuser role present',
                         "#{psql_super} \"SELECT rolsuper FROM pg_roles WHERE rolname='#{username}'\"", 't')
      # pg_hba.conf allows the account to authenticate (md5) from any host.
      test_local_command('pg_hba.conf line for the remote account',
                         "grep -E '^host[[:space:]]+all[[:space:]]+#{username}[[:space:]]+0\\.0\\.0\\.0/0[[:space:]]+md5' /etc/postgresql/15/main/pg_hba.conf",
                         'md5')
    end

    tier(2) do
      test_service_up(port: 5432)
      # The cluster is actually bound to every interface, not just loopback.
      test_local_command('server listening on all interfaces',
                         "ss -ltn 2>/dev/null | grep -E '(0\\.0\\.0\\.0|\\*):5432\\s'", ':5432')
      # The weak credentials are accepted over a TCP connection (not just the local
      # socket) and the account really is a superuser (can read pg_shadow).
      tcp = "PGPASSWORD=#{p} psql -h 127.0.0.1 -p 5432 -U #{u} -d template1 -tA"
      test_local_command('remote superuser authenticates over TCP',
                         "#{tcp} -c 'SELECT current_user' 2>/dev/null", username)
      test_local_command('account can read pg_shadow (superuser)',
                         "#{tcp} -c 'SELECT count(*) > 0 FROM pg_shadow' 2>/dev/null", 't')
      # A wrong password must be refused.
      bad = "PGPASSWORD=wrong-#{p} psql -h 127.0.0.1 -p 5432 -U #{u} -d template1 -tA -c 'SELECT 1' >/dev/null 2>&1; echo \"rc=$?\""
      test_local_command('wrong password is refused', bad, 'rc=2')
    end

    # Tier 3: the stock MSF auxiliary scanner authenticates with the weak superuser
    # credentials and dumps the password hashes from pg_shadow/pg_authid. It yields
    # no shell, so test_msf_exploit does not apply (the msf_module is auxiliary/...,
    # not exploit/..., and <privilege> is info_leak); run it with run_msf_module and
    # assert a crackable md5 hash came back.
    tier(3) do
      aux = run_msf_module('auxiliary/scanner/postgres/postgres_hashdump',
                           options: { 'USERNAME' => username, 'PASSWORD' => password, 'DATABASE' => 'template1' },
                           label: 'postgres hashdump')
      next unless aux

      out = aux[:msf_output].to_s
      # The remote superuser was created with an md5-encrypted password, so pg_shadow
      # holds an "md5" + 32 hex hash. postgres_hashdump reports each role's hash, so
      # at minimum a crackable md5 hash must appear in the loot.
      if out =~ /md5[0-9a-f]{32}/ && out.include?(username)
        pass_check('postgres_hashdump returns password hashes',
                   "postgres_hashdump on #{aux[:attacker]} dumped an md5 password hash and the role " \
                   "'#{username}' from #{aux[:rhost]}:5432 using the weak superuser credentials",
                   tier: 3)
      else
        fail_check('postgres_hashdump returns password hashes',
                   "No md5 hash for role '#{username}' in the postgres_hashdump output. " \
                   "See msf_output_postgres_hashdump evidence.",
                   tier: 3)
      end
    end
  end
end

PostgresHashdumpTest.new.run
