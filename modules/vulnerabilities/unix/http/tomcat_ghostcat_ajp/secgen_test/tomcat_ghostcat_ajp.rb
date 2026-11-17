require_relative '../../../../../lib/post_provision_test'

class TomcatGhostcatAjpTest < PostProvisionTest
  def initialize
    self.module_name = 'tomcat_ghostcat_ajp'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    catalina_base = '/opt/tomcat'
    server_xml    = "#{catalina_base}/conf/server.xml"
    webinf_dir    = "#{catalina_base}/webapps/ROOT/WEB-INF"

    # read_facts: leak_files pairs leaked_filenames[i] with strings_to_leak[i]
    # and writes each under WEB-INF. With the default generators there is one
    # pair, so the flag is webinf_dir/<leaked_filename> containing <string>.
    # The exact content (the leaked string) is a multi-line message, so its
    # byte-for-byte match is left to the tier-3 MSF read; tier 1 confirms the
    # file is planted, non-empty and owned by the tomcat service user.
    leaked_filename = json_inputs['leaked_filenames']&.first
    flag_path       = leaked_filename ? "#{webinf_dir}/#{leaked_filename}" : nil

    tier(1) do
      test_local_command('tomcat installed', 'test -x /opt/tomcat/bin/catalina.sh && echo ok', 'ok')
      # The AJP connector is present and configured for Ghostcat.
      test_local_command('AJP/1.3 connector configured',
                         "grep -F 'AJP/1.3' #{server_xml}", 'AJP/1.3')
      test_local_command('AJP bound to all interfaces',
                         "grep -F 'address=\"0.0.0.0\"' #{server_xml}", '0.0.0.0')
      test_local_command('AJP allows arbitrary request attributes (Ghostcat)',
                         "grep -F 'allowedRequestAttributesPattern=\".*\"' #{server_xml}",
                         'allowedRequestAttributesPattern')
      # The flag the exploit should read is planted under WEB-INF, non-empty
      # and owned by the tomcat user so the service can read it back.
      if flag_path
        esc = Shellwords.escape(flag_path)
        test_local_command('WEB-INF flag planted and non-empty',
                           "test -s #{esc} && echo PRESENT", 'PRESENT')
        test_local_command('WEB-INF flag owned by tomcat',
                           "stat -c %U #{esc}", 'tomcat')
      end
    end

    tier(2) do
      # Tomcat still serves its default app over HTTP.
      test_service_up(port: 8080)
      test_http('/', port: 8080, match: 'Apache Tomcat')
      # The AJP connector is reachable - this is the exposed attack surface.
      test_service_up(port: 8009)
      # The WEB-INF flag is NOT reachable over HTTP (Tomcat returns 404); that
      # is why it must be read through the Ghostcat AJP file read.
      if leaked_filename
        test_http("/WEB-INF/#{leaked_filename}", port: 8080, status: 404,
                  label: 'WEB-INF flag blocked over HTTP')
      end
    end

    # Tier 3 (exploit): the stock Metasploit auxiliary
    # auxiliary/admin/http/tomcat_ghostcat reads a file under the web app over
    # AJP (CVE-2020-1938). It gives no shell, so test_msf_exploit does not apply;
    # run_msf_module runs it on the attacker and we assert on the file contents it
    # prints in msf_output. SKIPs cleanly when the scenario has no attacker VM.
    #
    # AJP_PORT is set by the service module's server.xml (address="0.0.0.0"
    # port 8009); it is not a read_fact, so it is a constant here as in tier 2.
    tier(3) do
      ajp_port = 8009

      # Prefer reading the planted WEB-INF flag - that file is never served over
      # HTTP (tier 2 proves the 404), so reading it over AJP is the info leak.
      # The leaked string is multi-line; match its most distinctive word token so
      # the check survives however MSF reflows the file contents into its output.
      leaked_string = self.json_inputs['strings_to_leak']&.first
      token = leaked_string && leaked_string.scan(/\w{5,}/).max_by(&:length)

      if flag_path && token
        filename = "/WEB-INF/#{leaked_filename}"
        expected = token
        what     = "planted WEB-INF flag #{filename}"
      else
        # No planted flag (or no distinctive token): fall back to WEB-INF/web.xml,
        # which every Tomcat web app has and which is also blocked over HTTP.
        filename = '/WEB-INF/web.xml'
        expected = '</web-app>'
        what     = 'WEB-INF/web.xml'
      end

      aux = run_msf_module('auxiliary/admin/http/tomcat_ghostcat',
                           options: { 'RPORT' => ajp_port, 'FILENAME' => filename },
                           label: 'ghostcat ajp file read')
      next unless aux

      if aux[:msf_output].include?(expected)
        pass_check('ghostcat ajp file read',
                   "Ghostcat confirmed: MSF auxiliary on #{aux[:attacker]} read " \
                   "#{what} from //#{aux[:rhost]}:#{ajp_port} over AJP " \
                   "(expected content present in msf_output).",
                   tier: 3)
      else
        fail_check('ghostcat ajp file read',
                   "Could not read #{what} over AJP - expected content not found " \
                   "in msf_output. See msf_output_tomcat_ghostcat evidence.",
                   tier: 3)
      end
    end
  end
end

TomcatGhostcatAjpTest.new.run
