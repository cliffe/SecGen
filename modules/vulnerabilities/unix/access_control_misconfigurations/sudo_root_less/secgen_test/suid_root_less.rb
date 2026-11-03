require_relative '../../../../../lib/post_provision_test'


class SudoLessTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo_root_less'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    pre_leak  = self.json_inputs['pre_leak_filename']&.first.to_s
    pre_str   = self.json_inputs['strings_to_pre_leak']&.first.to_s.strip
    leaked    = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    return skip_check('sudo less', 'no pre_leak_filename input') if pre_leak.empty?

    pre_path = Shellwords.escape("/root/#{pre_leak}")
    tier(1) do
      test_local_command("#{pre_leak} root-only in /root", "stat -c '%U:%G %a' #{pre_path}", 'root:root 600')
      leaked.each do |f|
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
      # config.pp's sudo::conf entries
      test_local_command('sudoers lets ALL run less on the pre-leak file',
                         "grep -rhF 'NOPASSWD: /bin/less /root/#{pre_leak}' /etc/sudoers.d/", "/bin/less /root/#{pre_leak}")
    end
    tier(2) do
      # the misconfiguration: any user reads a root-only file through sudo less
      # (with no terminal less prints the file like cat)
      cmd = "sudo -n /bin/less #{pre_path}"
      if pre_str.empty?
        test_command_succeeds('unprivileged user reads the pre-leak file via sudo less', cmd, user: 'nobody')
      else
        test_local_command('unprivileged user reads the pre-leak file via sudo less', cmd, pre_str.lines.first.strip, user: 'nobody')
      end
    end
    # TODO tier 3 (exploit): escaping less to a root shell (!sh) needs a terminal
  end

end

SudoLessTest.new.run
