require_relative '../../../../../lib/post_provision_test'

class MysqlEnumMisconfigTest < PostProvisionTest
  # The mysql service module always listens on the standard MySQL port; this
  # module does not parameterise it, so the port is fixed.
  MYSQL_PORT = 3306

  def initialize
    self.module_name = 'mysql_enum_misconfig'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # read_facts: account_username, account_password, database_name are all
    # observable on the box (seeded account + grants), so each is checked below.
    username = self.json_inputs['account_username']&.first
    password = self.json_inputs['account_password']&.first
    database = self.json_inputs['database_name']&.first

    tier(1) do
      test_local_command('mariadb-server installed',
                         'dpkg -l mariadb-server 2>/dev/null | grep -E "^ii"', 'mariadb-server')
      test_local_command('remote bind config present',
                         'cat /etc/mysql/conf.d/99-secgen-remote.cnf', 'bind-address = 0.0.0.0')
      if username
        # The weak remote account was seeded with a wildcard host.
        test_local_command('weak remote account seeded',
                           "mysql -N -B -e \"SELECT CONCAT(user,'@',host) FROM mysql.user " \
                           "WHERE user='#{username}' AND host='%'\"", "#{username}@%")
      end
      # The anonymous/blank-password account was seeded.
      test_local_command('anonymous account seeded',
                         "mysql -N -B -e \"SELECT COUNT(*) FROM mysql.user " \
                         "WHERE user='' AND host='%'\"", '1')
      if database
        test_local_command('application database created',
                           "mysql -N -B -e \"SHOW DATABASES LIKE '#{database}'\"", database)
      end
    end

    tier(2) do
      # bind-address 0.0.0.0 means the server answers on all interfaces.
      test_local_command('listening on all interfaces',
                         "ss -ltn 2>/dev/null | grep ':#{MYSQL_PORT}'", "0.0.0.0:#{MYSQL_PORT}")
      test_service_up(port: MYSQL_PORT)
      # The weak account authenticates over a TCP (network) connection.
      if username && password
        test_local_command('remote account authenticates over TCP',
                           "mysql -h 127.0.0.1 --protocol=TCP -u #{username} " \
                           "-p#{password} -N -B -e 'SELECT 1 AS reachable' 2>&1", '1')
      end
    end

    # Tier 3: the MSF auxiliary authenticates with the weak account and audits the
    # server. It gives no shell, so test_msf_exploit does not apply; run_msf_module
    # drives it and we assert the CIS-style findings appear in its output.
    tier(3) do
      skip!('tier 3 needs the weak account credentials') unless username && password

      aux = run_msf_module('auxiliary/admin/mysql/mysql_enum',
                           options: { 'USERNAME' => username, 'PASSWORD' => password,
                                      'RPORT' => MYSQL_PORT },
                           label: 'mysql_enum audit')
      next unless aux

      out = aux[:msf_output]
      findings = {
        'anonymous account'    => 'Anonymous Accounts are Present',
        'blank password'       => 'empty passwords',
        'wildcard host'        => 'not restricted by source',
        'FILE privilege'       => 'FILE Privilege',
        'GRANT privilege'      => 'GRANT Privilege',
      }
      missing = findings.reject { |_label, marker| out.include?(marker) }

      if missing.empty?
        pass_check('mysql_enum reports seeded weaknesses',
                   "mysql_enum on #{aux[:attacker]} authenticated as #{username} against " \
                   "#{aux[:rhost]} and reported all seeded CIS-style findings: " \
                   "#{findings.keys.join(', ')}.",
                   tier: 3)
      else
        fail_check('mysql_enum reports seeded weaknesses',
                   "mysql_enum did not report: #{missing.keys.join(', ')}. " \
                   "See msf_output_mysql_enum evidence for the full audit output.",
                   tier: 3)
      end
    end

    # All three read_facts are checked above: account_username and database_name
    # against mysql.user / SHOW DATABASES, account_password via the TCP login.
  end
end

MysqlEnumMisconfigTest.new.run
