require_relative '../../../../../lib/post_provision_test'

class ApacheSparkRceTest < PostProvisionTest
  def initialize
    self.module_name = 'apache_spark_rce'
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
      test_local_command('spark install exists', 'test -d /usr/local/spark && echo present', 'present')
      test_local_command('java available', 'java -version 2>&1', 'version')
    end

    # leaked_filenames/strings_to_leak: leak_files writes these into the
    # exploited user's home directory, where the command injection reads them from
    tier(1) do
      self.json_inputs['leaked_filenames']&.each_with_index do |filename, i|
        leaked_string = self.json_inputs['strings_to_leak']&.at(i)
        leak_path = "/home/#{username}/#{filename}"
        test_local_command("leaked file #{filename} present", "test -f #{leak_path} && echo ok", 'ok')
        if leaked_string
          test_local_command("leaked file #{filename} contains expected string", "cat #{leak_path}", leaked_string)
        end
      end
    end

    tier(2) do
      test_service_up
      # Spark UI returns an HTML page with "Spark" in the title
      test_http('/', match: 'Spark')
    end
    test_msf_exploit('exploit/linux/http/apache_spark_rce_cve_2022_33891',
                     rport: self.port,
                     expect_privilege: 'user_rwx',
                     tier: 3)
  end
end

ApacheSparkRceTest.new.run
