require_relative '../../../../../lib/post_provision_test'

class NostromoCodeExecTest < PostProvisionTest
  def initialize
    self.module_name = 'nostromo_code_exec'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('nostromousr exists', 'id nostromousr', 'nostromousr')
      # nhttpd binary is built from source and installed under the user's home
      test_local_command('nhttpd binary exists', 'find /home/nostromousr -name "nhttpd" | head -1', 'nhttpd')
    end

    # leaked_filenames/strings_to_leak: leak_files writes these into the
    # nostromousr home directory, where the traversal exploit reads them from
    tier(1) do
      self.json_inputs['leaked_filenames']&.each_with_index do |filename, i|
        leaked_string = self.json_inputs['strings_to_leak']&.at(i)
        leak_path = "/home/nostromousr/#{filename}"
        test_local_command("leaked file #{filename} present", "test -f #{leak_path} && echo ok", 'ok')
        if leaked_string
          test_local_command("leaked file #{filename} contains expected string", "cat #{leak_path}", leaked_string)
        end
      end
    end

    tier(2) do
      test_service_up
      # Nostromo serves the pre-leaked content on its index page
      pre_leak = self.json_inputs['strings_to_pre_leak']&.first
      test_http('/', match: pre_leak)
    end
    test_msf_exploit('exploit/multi/http/nostromo_code_exec',
                     rport: self.port,
                     tier: 3)
  end
end

NostromoCodeExecTest.new.run
