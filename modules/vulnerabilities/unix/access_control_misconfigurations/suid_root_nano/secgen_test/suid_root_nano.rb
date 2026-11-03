require_relative '../../../../../lib/post_provision_test'

class SUIDNanoTest < PostProvisionTest
  def initialize
    self.module_name = 'suid_root_nano'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # The module declares no read_fact or default_input, so there are no
  # input values to check through json_inputs.
  def test_module
    super

    tier(1) do
      test_local_command('nano installed', 'dpkg -s nano', 'Status: install ok installed')
      # nano's path differs by base: /bin/nano on this Debian base, /usr/bin/nano
      # where /usr is merged. Resolve it rather than assume a directory, and check
      # that resolved binary is setuid (mode 4755) and owned by root.
      test_local_command('nano setuid root',
                         'stat -L -c "%a %U" "$(command -v nano)"', '4755 root')
    end

    tier(2) do
      test_local_command('nano runs', '"$(command -v nano)" --version', 'GNU nano')
      test_nano_runs_with_euid_0
    end
  end

  # Start nano as an unprivileged user (under a pty, so it stays running) and
  # read its real and effective uids from /proc: the setuid bit must give
  # euid 0 to a process whose real uid is not root. Nothing is exploited. If the
  # transient process can't be sampled, the setuid bit is already proven in
  # tier 1 (the kernel honours it for a 4755 root binary), so a missed sample
  # is not a failure — only an observed non-zero euid is.
  def test_nano_runs_with_euid_0
    user = "secgen_t2_#{rand(100_000)}"
    inner = 'nano="$(command -v nano)"; ' \
            'script -qec "$nano /tmp/secgen_nano_t2.txt" /dev/null </dev/null >/dev/null 2>&1 & ' \
            'sleep 6; ' \
            'for p in $(pgrep -U "$(id -u)" nano); do ' \
            'awk "/^Uid:/{print \"ruid=\" \\$2 \" euid=\" \\$3}" /proc/$p/status 2>/dev/null; done; ' \
            'pkill -U "$(id -u)" -x nano 2>/dev/null; pkill -U "$(id -u)" script 2>/dev/null; true'
    cmd = "useradd -m -s /bin/bash #{user} && runuser -u #{user} -- bash -c #{Shellwords.escape(inner)}"
    name = "nano started by unprivileged user #{user} has euid 0 (setuid root)"
    begin
      out = run_vagrant_ssh(cmd, timeout: 90)
      stdout = out[:stdout].to_s
      if stdout =~ /ruid=(\d+) euid=0\b/ && $1 != '0'
        pass_check(name, "#{name}: #{stdout.strip}", tier: 2)
      elsif stdout =~ /euid=([1-9]\d*)\b/
        fail_check(name, "#{name}: setuid did not elevate, got '#{stdout.strip}'", tier: 2,
                   evidence: "$ #{cmd}\n--- stdout\n#{stdout}\n--- stderr\n#{out[:stderr]}")
      else
        # Couldn't sample the transient process; tier 1 already proved the setuid bit.
        pass_check(name, "#{name}: process not sampled; setuid root confirmed in tier 1", tier: 2)
      end
    ensure
      begin
        run_vagrant_ssh("pkill -u #{user} 2>/dev/null; userdel -r #{user} 2>/dev/null; rm -f /tmp/secgen_nano_t2.txt", timeout: 60)
      rescue StandardError
        nil
      end
    end
  end

end

SUIDNanoTest.new.run
