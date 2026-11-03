require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class CronWritableScriptTest < PostProvisionTest
  # Account with no special rights, used to show the script is writable by
  # someone other than its owner.
  LOW_PRIV_USER = 'nobody'

  def initialize
    self.module_name = 'cron_writable_script'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Inputs: cron_location, cron_user, cron_message, leaked_filenames and
    # strings_to_leak are all checked below. Each falls back to the module's
    # own default when absent.
    cron_location = (json_inputs['cron_location']&.first || '/opt').sub(%r{/+\z}, '')
    cron_user     = json_inputs['cron_user']&.first || 'root'
    script        = "#{cron_location}/cron.sh"
    leak_dir      = cron_user == 'root' ? '/root' : "/home/#{cron_user}"
    q_script      = Shellwords.escape(script)

    # First line of the message is enough to recognise a run in the log.
    message_line = (json_inputs['cron_message']&.first || 'hello from cron').lines.map(&:strip).find { |l| !l.empty? }

    filenames = json_inputs['leaked_filenames'] || []
    strings   = json_inputs['strings_to_leak'] || []

    tier(1) do
      test_local_command('cron script is present and world-writable', "stat -c '%a %U' #{q_script}", '777 root')
      test_local_command('script runs from the configured shell', "head -n1 #{q_script}", '#!/bin/bash')
      test_local_command("cron entry exists for #{cron_user}", "crontab -l -u #{Shellwords.escape(cron_user)}", script)

      # leak_files pairs strings with filenames; extra strings go in the first file.
      strings.each_with_index do |str, i|
        file = filenames[i] || filenames.first
        next unless file
        path = Shellwords.escape("#{leak_dir}/#{file}")
        test_local_command("leaked string #{i + 1} is in #{leak_dir}/#{file}", "cat #{path}", str)
      end
    end

    tier(2) do
      # The misconfiguration as a low-privilege account sees it. Appending
      # nothing opens the file for writing without changing its content.
      test_command_succeeds("#{LOW_PRIV_USER} can open the cron script for writing", ": >> #{q_script}", user: LOW_PRIV_USER)

      # Cron actually runs the script: wait for the next minute boundary or two.
      if message_line
        found = false
        8.times do
          out = run_command('cat /tmp/cron.log 2>/dev/null')
          if out[:stdout].include?(message_line)
            found = true
            break
          end
          sleep 20
        end
        if found
          pass_check('cron ran the script and logged its message', "cron ran #{script} as #{cron_user}")
        else
          fail_check('cron ran the script and logged its message', "message not in /tmp/cron.log after 160s",
                     evidence: run_command("cat /tmp/cron.log 2>&1; systemctl is-active cron; crontab -l -u #{Shellwords.escape(cron_user)} 2>&1")[:stdout])
        end
      end
    end

    # No tier 3 here: not requested for this issue.
  end
end

CronWritableScriptTest.new.run
