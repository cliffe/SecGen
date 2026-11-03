require_relative '../../../../../lib/post_provision_test'

# JBoss AS 6.1.0.Final uses fixed ports (no port read_fact on this module):
# HTTP web connector on 8080, JBoss Remoting unified invoker on 4446 (the
# port the RCE actually targets). Confirmed from the bundled distribution's
# default ServiceBindingManager set (ports-default) in
# server/default/conf/bindingservice.beans/META-INF/bindings-jboss-beans.xml:
# UnifiedInvokerConnector -> 4446. Port 4447 in that file is the unrelated
# HA RMI/JRMP invoker (jrmpha), not the unified invoker this exploit targets.
JBOSS_HTTP_PORT = 8080
JBOSS_REMOTING_PORT = 4446
JBOSS_INSTALL_DIR = '/opt/jboss-6.1.0.Final'

class JbossRemotingUnifiedInvokerRceTest < PostProvisionTest
  def initialize
    self.module_name = 'jboss_remoting_unified_invoker_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
      test_local_command('java available', 'java -version 2>&1', 'version')
      # install path encodes the CVE-matching version: JBoss AS 6.1.0.Final
      test_local_command('jboss 6.1.0.Final install exists',
                          "test -d #{JBOSS_INSTALL_DIR} && echo present", 'present')
    end

    # leaked_filenames/strings_to_leak: leak_files writes these into the
    # jboss user's home directory
    tier(1) do
      home = username ? "/home/#{username}" : nil
      if home
        self.json_inputs['leaked_filenames']&.each_with_index do |filename, i|
          leaked_string = self.json_inputs['strings_to_leak']&.at(i)
          leak_path = "#{home}/#{filename}"
          test_local_command("leaked file #{filename} present", "test -f #{leak_path} && echo ok", 'ok')
          if leaked_string
            test_local_command("leaked file #{filename} contains expected string", "cat #{leak_path}", leaked_string)
          end
        end
      end
    end

    tier(2) do
      # JBoss Remoting unified invoker — the vulnerable interface the exploit
      # targets (MSF default RPORT 4446). Checked first so generate-t3-test
      # infers the remoting port for the tier-3 call, not the HTTP connector.
      test_service_up(port: JBOSS_REMOTING_PORT)
      # HTTP web connector
      test_service_up(port: JBOSS_HTTP_PORT)
      test_http('/', port: JBOSS_HTTP_PORT, match: 'JBoss')
    end
    test_msf_exploit('exploit/multi/misc/jboss_remoting_unified_invoker_rce',
                     rport: 4446,
                     expect_privilege: 'user_rwx',
                     tier: 3)
  end
end

JbossRemotingUnifiedInvokerRceTest.new.run
