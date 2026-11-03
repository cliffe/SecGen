require_relative '../../../../../lib/post_provision_test'

class SudoRootMoreTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo_root_more'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # Inputs: pre_leak_filename and leaked_filenames are checked as root-only files;
    # strings_to_pre_leak is checked through sudo more. strings_to_leak is the
    # content of leaked_filenames (root-only, not readable by the test user), so
    # only the files' ownership and mode are checked.
    pre_leak = self.json_inputs['pre_leak_filename']&.first.to_s
    pre_str  = self.json_inputs['strings_to_pre_leak']&.first.to_s.strip
    leaked   = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    return skip_check('sudo more', 'no pre_leak_filename input') if pre_leak.empty?

    pre_path = Shellwords.escape("/root/#{pre_leak}")
    tier(1) do
      test_local_command("#{pre_leak} root-only in /root", "stat -c '%U:%G %a' #{pre_path}", 'root:root 600')
      leaked.each do |f|
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
      # config.pp's sudo::conf entry (file name is <priority>_users_sudo_more)
      test_local_command('sudoers file for the more rule is root:root 440',
                         "stat -c '%U:%G %a' /etc/sudoers.d/10_users_sudo_more", 'root:root 440')
      test_local_command('sudoers lets ALL run more on the pre-leak file',
                         "grep -hF 'NOPASSWD: /bin/more /root/#{pre_leak}' /etc/sudoers.d/10_users_sudo_more",
                         "/bin/more /root/#{pre_leak}")
      test_local_command('sudoers syntax is valid', 'visudo -c 2>&1', 'parsed OK')
    end
    tier(2) do
      # the rule applies to ALL, so an unprivileged account stands in for "any user"
      test_local_command('unprivileged user sees the more rule in sudo -n -l',
                         'sudo -n -l', "/bin/more /root/#{pre_leak}", user: 'nobody')
      test_command_succeeds('more binary runs', '/bin/more --version', user: 'nobody')
      # the misconfiguration: any user reads a root-only file through sudo more
      # (with no terminal more prints the file like cat)
      cmd = "sudo -n /bin/more #{pre_path}"
      if pre_str.empty?
        test_command_succeeds('unprivileged user reads the pre-leak file via sudo more', cmd, user: 'nobody')
      else
        test_local_command('unprivileged user reads the pre-leak file via sudo more', cmd, pre_str.lines.first.strip, user: 'nobody')
      end
    end
    # No tier 3: no Metasploit module for this misconfiguration; escaping more
    # to a root shell needs a terminal.
  end

end

SudoRootMoreTest.new.run
