require_relative '../../../../../lib/post_provision_test'

class TomcatManagerDefaultCredsTest < PostProvisionTest
  # The connector is fixed at 8080 by the required tomcat service module, which
  # this module does not reconfigure, so port is not a read_fact here.
  TOMCAT_PORT = 8080

  def initialize
    self.module_name = 'tomcat_manager_default_creds'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # read_facts: tomcat_manager_username / tomcat_manager_password drive the
    # weak account written into tomcat-users.xml and used to authenticate below.
    username = (json_inputs['tomcat_manager_username'] || ['tomcat']).first
    password = (json_inputs['tomcat_manager_password'] || ['tomcat']).first

    users_xml   = '/opt/tomcat/conf/tomcat-users.xml'
    manager_ctx = '/opt/tomcat/webapps/manager/META-INF/context.xml'

    tier(1) do
      test_local_command('manager app present', 'test -d /opt/tomcat/webapps/manager && echo ok', 'ok')
      test_file_contains(users_xml, 'manager-gui', label: 'manager-gui role configured')
      test_file_contains(users_xml, "username=\"#{username}\"", label: 'weak manager user configured')
      # The stock localhost-only RemoteAddrValve must be gone for remote reach.
      # Match the actual <Valve className="...RemoteAddrValve"> element, not any
      # mention of the name in a comment, so the check reflects the real config.
      test_local_command('RemoteAddrValve removed from manager context',
                         "grep -Eq 'className=\"[^\"]*RemoteAddrValve\"' #{manager_ctx} && echo present || echo absent", 'absent')
    end

    tier(2) do
      test_service_up(port: TOMCAT_PORT)
      # the Manager app enforces auth: no credentials => 401
      test_http('/manager/html', status: 401, port: TOMCAT_PORT, label: 'manager requires authentication')
      # and the weak account authenticates (manager-script text interface)
      test_local_command('weak manager creds authenticate',
                         "curl -s -o /dev/null -w '%{http_code}' -u #{username}:#{password} " \
                         "http://localhost:#{TOMCAT_PORT}/manager/text/serverinfo",
                         '200')
    end

    # Tier 3: the stock MSF auxiliary login scanner proves the weak Manager
    # credential is remotely usable. It is an auxiliary module (no RCE / shell),
    # so run_msf_module drives it and we assert on its output rather than using
    # test_msf_exploit. RHOSTS is set by the helper; we scope the scan to the
    # single configured user/password (threaded from json_inputs, same values as
    # tier 2) with STOP_ON_SUCCESS and no blank-password guesses, so a success
    # line can only mean the module's own credential authenticated.
    tier(3) do
      aux = run_msf_module('auxiliary/scanner/http/tomcat_mgr_login',
                           options: {
                             'RPORT'           => TOMCAT_PORT,
                             'USERNAME'        => username,
                             'PASSWORD'        => password,
                             'STOP_ON_SUCCESS' => true,
                             'BLANK_PASSWORDS' => false,
                           },
                           label: 'tomcat manager weak-cred login')
      next unless aux

      msf_output = aux[:msf_output]
      # tomcat_mgr_login prints: [+] <host> - Login Successful: <user>:<pass>
      if msf_output =~ /Login Successful:\s*#{Regexp.escape(username)}:/
        pass_check('tomcat manager weak-cred login',
                   "tomcat_mgr_login on #{aux[:attacker]} authenticated to " \
                   "http://#{aux[:rhost]}:#{TOMCAT_PORT}/manager as #{username}.",
                   tier: 3)
      elsif msf_output.include?('Login Successful')
        # Authenticated, but not as the configured user — still proves the
        # Manager accepts a weak credential, but flag the mismatch for review.
        pass_check('tomcat manager weak-cred login',
                   "tomcat_mgr_login on #{aux[:attacker]} reported a successful " \
                   "login against http://#{aux[:rhost]}:#{TOMCAT_PORT}/manager, " \
                   "though not clearly as #{username}. See msf_output evidence.",
                   tier: 3)
      else
        fail_check('tomcat manager weak-cred login',
                   "tomcat_mgr_login did not report 'Login Successful' for " \
                   "#{username} against http://#{aux[:rhost]}:#{TOMCAT_PORT}/manager. " \
                   "See msf_output_tomcat_mgr_login evidence for the scanner output.",
                   tier: 3)
      end
    end
  end
end

TomcatManagerDefaultCredsTest.new.run
