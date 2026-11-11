require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class MysqlRemoteHashdumpTest < PostProvisionTest
  def initialize
    self.module_name = 'mysql_remote_hashdump'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Both inputs are observable on the box and are checked below.
    #   username / password — the remote DBA account and its weak password.
    # MySQL/MariaDB always listens on the fixed port 3306, so there is no port
    # input to read; the port is hardcoded like the mysql service's own test.
    username = self.json_inputs['username']&.first || 'dbadmin'
    password = self.json_inputs['password']&.first || 'password123'
    u = Shellwords.escape(username)
    p = Shellwords.escape(password)

    tier(1) do
      # The required mysql service is installed.
      test_local_command('mysql server installed', 'dpkg -l | grep -E "^ii\s+(mysql|mariadb)-server"', 'server')
      # The drop-in that opens the server to the network is in place.
      test_local_command('bind-address opened to all interfaces',
                         'grep bind-address /etc/mysql/conf.d/zz_secgen_remote_access.cnf', '0.0.0.0')
      # The remote account exists in mysql.user (root uses the local socket).
      test_local_command('remote account present in mysql.user',
                         "mysql -N -e \"SELECT User FROM mysql.user WHERE User='#{username}'\"", username)
    end

    tier(2) do
      test_service_up(port: 3306)
      # The server is actually bound to every interface, not just loopback.
      test_local_command('server listening on 0.0.0.0:3306', 'ss -ltn 2>/dev/null', '0.0.0.0:3306')
      # The weak credentials are accepted over a TCP connection (not just the
      # local socket); CURRENT_USER() echoes the account the server matched.
      test_local_command('remote account authenticates over TCP',
                         "mysql -h 127.0.0.1 --protocol=tcp -u #{u} -p#{p} -N -e 'SELECT CURRENT_USER()' 2>/dev/null",
                         username)
    end

    # Tier 3: the stock MSF auxiliary scanner authenticates with the weak
    # credentials and dumps mysql.user. It yields no shell, so test_msf_exploit
    # does not apply (the msf_module is auxiliary/..., not exploit/...); run it
    # with run_msf_module and assert a native-password hash came back.
    tier(3) do
      aux = run_msf_module('auxiliary/scanner/mysql/mysql_hashdump',
                           options: { 'USERNAME' => username, 'PASSWORD' => password },
                           label: 'mysql hashdump')
      next unless aux

      out = aux[:msf_output].to_s
      # mysql_hashdump prints each dumped account as "user:*<40 hex>". The remote
      # account was created with a mysql_native_password hash, so at minimum its
      # own hash must appear.
      if out =~ /#{Regexp.escape(username)}:\*[0-9A-Fa-f]{40}/
        pass_check('mysql_hashdump returns password hashes',
                   "mysql_hashdump on #{aux[:attacker]} dumped a native-password hash for " \
                   "'#{username}' from #{aux[:rhost]}:3306 using the weak credentials",
                   tier: 3)
      else
        fail_check('mysql_hashdump returns password hashes',
                   "No native-password hash for '#{username}' in the mysql_hashdump output. " \
                   "See msf_output_mysql_hashdump evidence.",
                   tier: 3)
      end
    end
  end
end

MysqlRemoteHashdumpTest.new.run
