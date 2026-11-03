require_relative '../../../../../lib/post_provision_test'


class SudoRootAptGetTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo_root_apt_get'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs checked: sudo_user (who the rule is for; default ALL), strings_to_leak
  # and leaked_filenames (root-only files in /root).
  # Probe account: nobody (exists on every base) when the rule is for ALL,
  # otherwise the sudo_user itself, and nobody must then be refused.
  def test_module
    super
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)
    files   = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    sudo_user = Array(self.json_inputs['sudo_user']).map(&:to_s).first.to_s.strip
    sudo_user = 'ALL' if sudo_user.empty?
    probe   = sudo_user == 'ALL' ? 'nobody' : sudo_user
    sudoers = '/etc/sudoers.d/10_users_sudo_apt_get'

    tier(1) do
      test_local_command('apt-get binary present', 'test -x /usr/bin/apt-get && echo present', 'present')
      test_local_command('sudoers drop-in is root:root 440', "stat -c '%U:%G %a' #{sudoers}", 'root:root 440')
      test_local_command("sudoers lets #{sudo_user} run apt-get as root with no password",
                         "grep -F 'NOPASSWD: /usr/bin/apt-get *' #{sudoers} | awk '{print $1}'", sudo_user)
      test_local_command('sudoers rule is apt-get as root with no password',
                         "grep -F 'NOPASSWD: /usr/bin/apt-get *' #{sudoers}", 'ALL=(root) NOPASSWD: /usr/bin/apt-get *')
      test_local_command("sudoers lets #{sudo_user} list their sudo rights with no password",
                         "grep -rhF 'NOPASSWD: /usr/bin/sudo -l' /etc/sudoers.d/ | awk '{print $1}'", sudo_user)
      test_command_succeeds('sudoers syntax is valid', 'visudo -c')

      # leak_files pairs strings with filenames; extra strings are appended to the first file
      files.each_with_index do |f, i|
        path = Shellwords.escape("/root/#{f}")
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{path}", 'root:root 600')
        expected = (strings[i] || '').lines.first.to_s.strip
        test_local_command("#{f} holds its leaked string", "cat #{path}", expected) unless expected.empty?
      end
    end

    tier(2) do
      # sudo -n never prompts, so a missing NOPASSWD rule fails rather than hangs
      test_local_command("#{probe} is allowed apt-get as root without a password",
                         'sudo -n -l 2>&1', '(root) NOPASSWD: /usr/bin/apt-get *', user: probe)
      test_local_command("#{probe} runs apt-get through sudo",
                         'sudo -n /usr/bin/apt-get --version 2>&1', 'apt ', user: probe)
      # a rule scoped to one account must not reach the others
      unless sudo_user == 'ALL'
        test_local_command('another unprivileged user (nobody) is refused apt-get through sudo',
                           'sudo -n /usr/bin/apt-get --version >/dev/null 2>&1 && echo ALLOWED || echo REFUSED',
                           'REFUSED', user: 'nobody')
      end
      # the rule only matters if the root-only files are out of reach without it
      files.first(1).each do |f|
        test_local_command('root-only file is unreadable to the same user without sudo',
                           "cat #{Shellwords.escape("/root/#{f}")} 2>&1", 'Permission denied', user: probe)
      end
    end
    # No tier 3: no Metasploit module for this misconfiguration, and the
    # apt-get changelog pager escape (!sh) needs a terminal.
  end

end

SudoRootAptGetTest.new.run
