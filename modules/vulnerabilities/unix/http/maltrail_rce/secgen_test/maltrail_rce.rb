require_relative '../../../../../lib/post_provision_test'
require 'json'

class MaltrailRceTest < PostProvisionTest
  def initialize
    self.module_name = 'maltrail_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      test_local_command('python3 installed?', 'which python3', '/python3')
      test_local_command('maltrail installed under /opt', 'test -f /opt/maltrail/server.py && echo ok', 'ok')
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
    end

    # leaked_filenames/strings_to_leak: flag 1, dropped into the service user's home directory.
    # secgen_functions::leak_files pairs strings_to_leak[i] with leaked_filenames[i], and any
    # extra strings beyond the number of filenames are appended to the first filename.
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
      # '/login' with no credentials returns 401 "Login failed" (no auth configured, so this
      # just exercises the handler) - check the web UI itself answers instead.
      test_http('/', match: 'maltrail')
    end

    # maltrail_data: flag 2, embedded within the generated threat data (custom trails file)
    if (maltrail_data_json = self.json_inputs['maltrail_data']&.first)
      data = JSON.parse(maltrail_data_json)
      if (flag_event = data['flag_event'])
        tier(2) do
          test_local_command('custom trails file contains embedded flag domain',
                             'cat /opt/maltrail/trails/custom.txt', flag_event['trail'])
          test_local_command('custom trails file contains embedded flag string',
                             'cat /opt/maltrail/trails/custom.txt', flag_event['trail_info'])
        end
      end
    end
    test_msf_exploit('exploit/unix/http/maltrail_rce',
                     rport: self.port,
                     tier: 3)
  end
end

MaltrailRceTest.new.run
