require_relative '../../../../../lib/post_provision_test'

class SpringCloudGatewayRceTest < PostProvisionTest
  def initialize
    self.module_name = 'spring_cloud_gateway_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # read_facts: port (listen port, via self.port), unix_username (service user),
  # strings_to_leak + leaked_filenames (flag dropped in that user's home). All
  # four drive observable state and are checked below; none are skipped.
  def test_module
    super
    username = self.json_inputs['unix_username']&.first
    jar = '/opt/scg/scg-gateway.jar'

    tier(1) do
      test_local_command('java available', 'java -version 2>&1', 'openjdk')
      test_local_command('gateway fat jar deployed', "test -f #{jar} && echo present", 'present')
      # Confirms the bundled Spring Cloud Gateway is the vulnerable 3.1.0 (fix in 3.1.1).
      test_local_command('spring-cloud-gateway 3.1.0 bundled',
                         "jar tf #{jar} | grep gateway-server",
                         'spring-cloud-gateway-server-3.1.0.jar')
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
    end

    # The flag leaked into the gateway user's home (configure.pp's leak_files);
    # on the box it proves the flag is placed where SpEL-injection RCE as that
    # user would reach it, matching <privilege>user_rwx</privilege>.
    storage_dir = username ? "/home/#{username}" : nil
    leaked_filenames = self.json_inputs['leaked_filenames'] || []
    strings_to_leak = self.json_inputs['strings_to_leak'] || []
    if storage_dir && leaked_filenames.any?
      tier(1) do
        leaked_filenames.each do |filename|
          test_local_command("leaked file #{filename} present", "test -f #{storage_dir}/#{filename} && echo ok", 'ok')
        end
      end
      tier(2) do
        strings_to_leak.each_with_index do |string, i|
          filename = leaked_filenames[i] || leaked_filenames.first
          test_local_command("#{filename} contains leaked string ##{i}", "cat #{storage_dir}/#{filename}", string)
        end
      end
    end

    tier(2) do
      test_service_up
      # The actuator gateway endpoint is the vulnerable surface: exposed here
      # (an empty routes array when unexploited), it is what the exploit POSTs a
      # SpEL-bearing route to. A 2xx response proves it is reachable.
      test_http('/actuator/gateway/routes', match: nil)
    end

    tier(3) do 
      test_msf_exploit('exploit/linux/http/spring_cloud_gateway_rce',
                       rport: self.port,
                       expect_privilege: 'user_rwx',
                       tier: 3)
    end
  end
end

SpringCloudGatewayRceTest.new.run
