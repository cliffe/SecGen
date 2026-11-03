require_relative '../../../../../lib/post_provision_test'

class LuceeRceTest < PostProvisionTest
  def initialize
    self.module_name = 'lucee_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      test_local_command('java available', 'java -version 2>&1', 'version')
      # Lucee Express is unpacked to /usr/local/src (see install.pp); lucee.service
      # (templates/lucee.service.erb) runs this start script.
      test_local_command('lucee start script', 'test -f /usr/local/src/bin/startup.sh && echo present', 'present')
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
    end

    # strings_to_leak/leaked_filenames: the arbitrary-file-write flag, dropped into the
    # Lucee process user's home directory (configure.pp's leak_files call). Reachable only
    # after exploiting the vulnerability as that user, matching <privilege>user_rwx</privilege>.
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
      # Lucee Administrator login page; content varies by build so only the port/HTTP
      # response is asserted here.
      test_http('/lucee/admin/server.cfm', match: nil)
    end
    # cmd/unix/generic refuses to run when the exploit leaves files it cannot auto-remove,
    # aborting with "cannot cleanup files created during exploit" before the CMD executes.
    # CVE-2021-21307 is an arbitrary file write (it drops a CFM file it cannot clean up),
    # so allow it; the sentinel CMD then runs and confirms RCE as the Tomcat user.
    test_msf_exploit('exploit/linux/http/lucee_admin_imgprocess_file_write',
                     rport: self.port,
                     expect_privilege: 'user_rwx',
                     options: { 'AllowNoCleanup' => true },
                     tier: 3)
  end
end

LuceeRceTest.new.run
