require_relative '../../../../../lib/post_provision_test'

class FingerdTest < PostProvisionTest
  # The metadata declares no read_fact or default_input, so there are no inputs
  # to check; finger is on its standard port, 79.
  FINGER_PORT = 79

  def initialize
    self.module_name = 'fingerd'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = FINGER_PORT
  end

  def test_module
    super
    # Tier 1: daemon binary and the inetd entry that starts it
    test_command_succeeds('in.fingerd installed', 'test -x /usr/sbin/in.fingerd', tier: 1)
    test_local_command('openbsd-inetd installed', 'dpkg -l openbsd-inetd | grep -E "^ii"', 'openbsd-inetd', tier: 1)
    test_local_command('inetd.conf lists finger', 'grep -E "^finger[[:space:]]" /etc/inetd.conf', 'in.fingerd', tier: 1)

    # Tier 2: inetd is listening on 79 and fingerd answers with the account list
    test_service_up
    test_local_command('inetd process running', 'ps -ef | grep "[i]netd"', 'inetd', tier: 2)
    # A non-system account is chosen from the box so this holds for any scenario's accounts.
    user = run_command("awk -F: '$3>=1000 && $3<65534 {print $1; exit}' /etc/passwd")[:stdout].to_s.strip
    if user.empty?
      skip_check('finger reports a scenario account', 'no account with uid >= 1000 on this system', tier: 2)
    else
      query = "bash -c 'exec 3<>/dev/tcp/127.0.0.1/#{self.port}; printf \"#{user}\\r\\n\" >&3; timeout 5 cat <&3'"
      test_local_command("finger answers a query for #{user}", query, user, tier: 2)

      # From the attacker, the MSF scanner enumerates the account over the network (SKIP without an attacker VM).
      if attack_system
        file = '/tmp/finger_users.txt'
        run_on_system(attack_system, "printf '%s\\nnosuchuser_zz\\n' '#{user}' > #{file}")
        res = run_msf_module('auxiliary/scanner/finger/finger_users',
                             options: { 'RPORT' => self.port, 'USERS_FILE' => file },
                             tier: 2, label: 'finger_users from attacker')
        if res
          if res[:msf_output].include?("Found user: #{user}")
            pass_check('finger_users lists the scenario account', "found #{user}", tier: 2)
          else
            fail_check('finger_users lists the scenario account', "no 'Found user: #{user}' in output", tier: 2)
          end
        end
      end
    end
  end
end

FingerdTest.new.run
