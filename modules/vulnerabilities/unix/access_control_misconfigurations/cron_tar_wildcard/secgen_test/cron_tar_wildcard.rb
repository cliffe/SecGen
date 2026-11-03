require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class CronTarWildcardTest < PostProvisionTest
  ARCHIVE_DIR = '/var/spool/backups'.freeze # fixed in cron_tar_wildcard::config

  def initialize
    self.module_name = 'cron_tar_wildcard'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Resolved inputs. Defaults mirror the manifest's own fallbacks.
    cron_location = (json_inputs['cron_location']&.first.to_s.strip)
    cron_location = '/opt' if cron_location.empty?
    cron_user = (json_inputs['cron_user']&.first.to_s.strip)
    cron_user = 'root' if cron_user.empty?
    restrict_user = json_inputs['restrict_write_user']&.first.to_s.strip
    show_hint = json_inputs['show_crontab_hint']&.first.to_s =~ /\A(true|1|yes)\z/i ? true : false

    backup_dir = "#{cron_location}/backup"
    hint_file = "#{cron_location}/backup.txt"
    cron_cmd = "cd #{backup_dir} && tar -zcf #{ARCHIVE_DIR}/backup.tar.gz *"
    leak_dir = cron_user == 'root' ? '/root' : "/home/#{cron_user}"
    # Account that must be able to write to the backup directory, and one that must not.
    writer = restrict_user.empty? ? 'nobody' : restrict_user
    outsider = 'nobody'

    tier(1) do
      test_local_command('backup directory exists', "test -d #{Shellwords.escape(backup_dir)} && echo ok", 'ok')
      test_local_command('archive directory exists', "test -d #{ARCHIVE_DIR} && echo ok", 'ok')

      # Mode follows restrict_write_user: 0777 for anyone, else 0755 owned by that user.
      expected_mode = restrict_user.empty? ? '777 root' : "755 #{restrict_user}"
      test_local_command('backup directory mode and owner',
                         "stat -c '%a %U' #{Shellwords.escape(backup_dir)}", expected_mode)

      test_local_command('hint file shows the backup command',
                         "cat #{Shellwords.escape(hint_file)}", cron_cmd)
      # show_crontab_hint: the hint file points at sudo only when the switch is on.
      if show_hint
        test_local_command('hint file mentions sudo crontab -l',
                           "cat #{Shellwords.escape(hint_file)}", 'sudo crontab -l')
        test_local_command('sudoers permits crontab -l',
                           'grep -rh "crontab -l" /etc/sudoers /etc/sudoers.d',
                           restrict_user.empty? ? 'ALL' : restrict_user)
      else
        test_local_command('hint file has no sudo pointer',
                           "grep -c 'sudo' #{Shellwords.escape(hint_file)}; true", '0')
      end

      test_local_command("cron job for #{cron_user} runs tar with a wildcard",
                         "crontab -u #{Shellwords.escape(cron_user)} -l", cron_cmd)

      # leaked_filenames / strings_to_leak: leak_files writes each string into
      # its paired filename in the cron user's home, mode 0600.
      (json_inputs['leaked_filenames'] || []).each_with_index do |filename, i|
        path = "#{leak_dir}/#{filename}"
        test_local_command("leaked file #{filename} present", "test -f #{Shellwords.escape(path)} && echo ok", 'ok')
        if (leaked = json_inputs['strings_to_leak']&.at(i))
          test_local_command("leaked file #{filename} holds its string", "cat #{Shellwords.escape(path)}", leaked)
        end
      end
    end

    tier(2) do
      test_command_succeeds('cron service active', 'systemctl is-active --quiet cron')

      # The intended account can write into the backup directory ...
      probe = "#{backup_dir}/secgen_probe_#{Process.pid}"
      qprobe = Shellwords.escape(probe)
      test_command_succeeds("#{writer} can write to the backup directory",
                            "touch #{qprobe}", user: writer)

      # ... and, when restricted, nobody else can.
      unless restrict_user.empty?
        out = run_as_user(outsider, "touch #{Shellwords.escape(backup_dir)}/secgen_outsider 2>&1; echo rc=$?")
        if out[:stdout].to_s.include?('rc=0')
          fail_check("#{outsider} cannot write to the restricted backup directory",
                     "#{outsider} created a file in #{backup_dir} despite restrict_write_user=#{restrict_user}",
                     tier: 2, evidence: out.inspect)
        else
          pass_check("#{outsider} cannot write to the restricted backup directory",
                     "#{outsider} was refused write access to #{backup_dir}", tier: 2)
        end
        run_vagrant_ssh("rm -f #{Shellwords.escape(backup_dir)}/secgen_outsider")
      end

      # The scheduled job picks up what the writer put there: the probe file
      # appears in the archive within a few cron ticks. No injection involved.
      found = false
      8.times do
        listing = run_vagrant_ssh("tar -tzf #{ARCHIVE_DIR}/backup.tar.gz 2>/dev/null")
        if listing[:stdout].to_s.include?(File.basename(probe))
          found = true
          break
        end
        sleep 15
      end
      run_vagrant_ssh("rm -f #{qprobe}")
      if found
        pass_check('cron job archives files written by the low-privilege user',
                   "#{File.basename(probe)} appeared in #{ARCHIVE_DIR}/backup.tar.gz", tier: 2)
      else
        fail_check('cron job archives files written by the low-privilege user',
                   "#{File.basename(probe)} not in #{ARCHIVE_DIR}/backup.tar.gz after ~2 minutes", tier: 2,
                   evidence: run_vagrant_ssh("ls -la #{ARCHIVE_DIR}; crontab -u #{Shellwords.escape(cron_user)} -l; systemctl status cron 2>&1 | tail -5").inspect)
      end

      # The hint path: an ordinary user can list root's crontab through sudo.
      # `sudo crontab -l` shows root's crontab, so only meaningful when cron_user is root.
      if show_hint && cron_user == 'root'
        test_local_command("#{writer} sees the cron job via sudo crontab -l",
                           "#{as_user_command(writer, 'sudo -n crontab -l 2>&1')}", cron_cmd, tier: 2)
        unless restrict_user.empty?
          out = run_as_user(outsider, 'sudo -n crontab -l 2>&1; echo rc=$?')
          if out[:stdout].to_s.include?('rc=0')
            fail_check("#{outsider} cannot list crontab via sudo", "sudo crontab -l succeeded for #{outsider}",
                       tier: 2, evidence: out.inspect)
          else
            pass_check("#{outsider} cannot list crontab via sudo", "sudo crontab -l refused for #{outsider}", tier: 2)
          end
        end
      end
    end

    # No tier 3: this issue is scoped to tier 2. The tar checkpoint injection is
    # a local privilege escalation with no Metasploit module.
  end
end

CronTarWildcardTest.new.run
