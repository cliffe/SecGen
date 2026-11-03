require_relative '../../../../../lib/post_provision_test'

class LinuxkiRceTest < PostProvisionTest
  def initialize
    self.module_name = 'linuxki_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      test_local_command('linuxki package installed?', 'dpkg -l linuxki | grep -E "^ii"', 'linuxki')
      test_local_command('php installed?', 'php --version', 'PHP')
      # LinuxKI PHP scripts are served via Apache
      test_local_command('apache2 installed?', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
    end

    # leaked_filenames/strings_to_leak: flag, dropped into the configured user's home directory.
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
      # kivis.php (the exploit's entry point, under docroot /opt/) renders its
      # textarea form even with no query params - confirms PHP actually parses
      # the script (it fatals on Debian 12's stock PHP 8.2; see install.pp).
      test_http('/linuxki/experimental/vis/kivis.php', match: 'textarea')
    end
    # The exploit's default payload is php/meterpreter/reverse_tcp (a PHP-platform
    # module); the helper's default cmd/unix/generic is rejected as incompatible
    # ("cmd/unix/generic is not a compatible payload"). php/unix/cmd/generic is
    # the PHP-platform twin: a no-session command payload that runs CMD and
    # drops the sentinel without needing a reverse/bind shell. That payload
    # refuses to run without AllowNoCleanup ("cannot cleanup files created
    # during exploit") since our sentinel CMD isn't its own uploaded file.
    #
    # sentinel_dir: the RCE runs in a child of apache2.service, which ships with
    # PrivateTmp=true on Debian - the service sees its own private /tmp, so a
    # sentinel dropped in /tmp is invisible to the root guest-agent read that
    # verifies it (the exploit completes and the command runs, but the check
    # FAILs). /dev/shm (world-writable, 1777) is outside PrivateTmp's /tmp and
    # /var/tmp isolation, so the exploit and the verifying read see the same file.
    test_msf_exploit('exploit/linux/http/linuxki_rce',
                     rport: self.port,
                     payload: 'php/unix/cmd/generic',
                     options: { 'AllowNoCleanup' => true },
                     expect_privilege: 'user_rwx',
                     sentinel_dir: '/dev/shm',
                     tier: 3)
  end
end

LinuxkiRceTest.new.run
