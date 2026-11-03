require_relative '../../../../../lib/post_provision_test'


class SudoRootAptGetTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo_root_apt_get'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # The module grants every account (ALL), so there is no account input to read.
  # Inputs checked: strings_to_leak and leaked_filenames (root-only files in /root).
  # Unprivileged probe account: nobody (exists on every base).
  def test_module
    super
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)
    files   = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    sudoers = '/etc/sudoers.d/10_users_sudo_apt_get'

    tier(1) do
      test_local_command('apt-get binary present', 'test -x /usr/bin/apt-get && echo present', 'present')
      test_local_command('sudoers drop-in is root:root 440', "stat -c '%U:%G %a' #{sudoers}", 'root:root 440')
      test_local_command('sudoers lets ALL run apt-get as root with no password',
                         "grep -F 'NOPASSWD: /usr/bin/apt-get *' #{sudoers}", 'ALL=(root) NOPASSWD: /usr/bin/apt-get *')
      test_local_command('sudoers lets ALL list their sudo rights with no password',
                         "grep -rhF 'NOPASSWD: /usr/bin/sudo -l' /etc/sudoers.d/", '/usr/bin/sudo -l')
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
      test_local_command('unprivileged user is allowed apt-get as root without a password',
                         'sudo -n -l 2>&1', '(root) NOPASSWD: /usr/bin/apt-get *', user: 'nobody')
      test_local_command('unprivileged user runs apt-get through sudo',
                         'sudo -n /usr/bin/apt-get --version 2>&1', 'apt ', user: 'nobody')
      # the rule only matters if the root-only files are out of reach without it
      files.first(1).each do |f|
        test_local_command('root-only file is unreadable to the same user without sudo',
                           "cat #{Shellwords.escape("/root/#{f}")} 2>&1", 'Permission denied', user: 'nobody')
      end
    end
    # No tier 3: no Metasploit module for this misconfiguration, and the
    # apt-get changelog pager escape (!sh) needs a terminal.
  end

end

SudoRootAptGetTest.new.run
