require_relative '../../../../../lib/post_provision_test'

class ApacheUserdirEnumTest < PostProvisionTest
  # Apache listens on 80, fixed by the required apache service module; this
  # module declares no port read_fact, so the port is referenced directly.
  APACHE_PORT = 80

  def initialize
    self.module_name = 'apache_userdir_enum'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Resolved inputs — the test must hold for any parameterised deployment.
    usernames = (self.json_inputs['usernames'] || []).map(&:to_s).reject(&:empty?)

    # A username that is deliberately absent, used as the negative control at
    # tiers 2 and 3: it must answer 404 and must not be reported by the scanner.
    control = "secgen_absent_#{rand(1_000_000)}"

    tier(1) do
      test_local_command('apache installed',
                         'dpkg -l | grep -E "^ii\s+apache2\s"', 'apache2')
      # mod_userdir is enabled (the Forge apache module symlinks it into
      # mods-enabled) and its config is present.
      test_local_command('mod_userdir enabled',
                         'test -e /etc/apache2/mods-enabled/userdir.load && echo userdir_enabled', 'userdir_enabled')
      test_local_command('UserDir directive configured',
                         'grep -h "UserDir" /etc/apache2/mods-enabled/userdir.conf', 'UserDir')

      usernames.each do |user|
        esc = Shellwords.escape(user)
        test_local_command("account #{user} exists",
                           "getent passwd #{esc} >/dev/null && echo account_present", 'account_present')
        test_local_command("public_html for #{user} present",
                           "test -d /home/#{esc}/public_html && echo present", 'present')
      end
    end

    tier(2) do
      test_service_up(port: APACHE_PORT)
      # The 403-vs-404 oracle: an existing user's public_html (listing off, no
      # index) is 403 Forbidden; an absent user is 404 Not Found.
      usernames.each do |user|
        test_http("/~#{user}/", status: 403, port: APACHE_PORT,
                  label: "/~#{user}/ returns 403 (user exists)")
      end
      test_http("/~#{control}/", status: 404, port: APACHE_PORT,
                label: "/~#{control}/ returns 404 (user absent)")
    end

    # Tier 3: prove the enumeration from the Kali/MSF attacker with the stock
    # auxiliary scanner. It gives no shell (privilege is info_leak), so
    # test_msf_exploit does not apply — run_msf_module drives it and we assert on
    # its output. USER_FILE holds every valid username plus the absent control;
    # a genuine enumeration reports the valid users and not the control.
    tier(3) do
      next if usernames.empty?

      resolved = resolve_attacker('auxiliary/scanner/http/apache_userdir_enum', nil, nil, 3)
      next unless resolved
      attacker, _attacker_ip, rhost = resolved

      list_path = '/tmp/secgen_apache_userdir_list.txt'
      wordlist = (usernames + [control]).join('\n')
      run_on_system(attacker, "printf '%b\\n' #{Shellwords.escape(wordlist)} > #{list_path}")

      aux = run_msf_module('auxiliary/scanner/http/apache_userdir_enum',
                           attacker: attacker, rhost: rhost,
                           options: { 'USER_FILE' => list_path, 'RPORT' => APACHE_PORT,
                                      'VERBOSE' => false },
                           label: 'apache userdir enum')
      next unless aux

      out = aux[:msf_output].to_s
      found_all = usernames.all? { |u| out.include?(u) }
      control_leaked = out.include?(control)
      if found_all && !control_leaked
        pass_check('apache_userdir_enum reveals the valid usernames',
                   "Username enumeration confirmed: apache_userdir_enum on #{attacker} reported " \
                   "#{usernames.join(', ')} (403) through mod_userdir on #{rhost}:#{APACHE_PORT} " \
                   "and not the absent control #{control} (404)",
                   tier: 3)
      else
        fail_check('apache_userdir_enum reveals the valid usernames',
                   "Expected the scanner to report #{usernames.join(', ')} and not #{control}. " \
                   "found_all=#{found_all} control_leaked=#{control_leaked}. " \
                   "See msf_output_apache_userdir_enum evidence.",
                   tier: 3)
      end
    end

    # Input checked above: usernames drives the account/public_html, 403 and
    # scanner assertions. This module declares no other read_facts.
  end
end

ApacheUserdirEnumTest.new.run
