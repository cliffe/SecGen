require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class WritableGroupsTest < PostProvisionTest
  # An account with no sudo rights and no shell privileges of its own; the
  # misconfiguration must let it modify /etc/group.
  LOW_PRIV_USER = 'nobody'

  def initialize
    self.module_name = 'writable_groups'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Inputs: strings_to_leak and leaked_filenames are paired up by
    # secgen_functions::leak_files and written to /root/<filename>. Surplus
    # strings are appended to the first file, so each string is checked
    # against the file it was paired with (or the first file).
    strings   = self.json_inputs['strings_to_leak'] || []
    filenames = (self.json_inputs['leaked_filenames'] || []).reject { |f| f.to_s.empty? }

    tier(1) do
      test_local_command('/etc/group is world-writable', 'stat -c %a /etc/group', '777')
      test_local_command('/etc/group is still a group file', 'grep -c "^root:x:0:" /etc/group', '1')

      filenames.each do |filename|
        test_command_succeeds("leaked file /root/#{filename} exists", "test -f #{Shellwords.escape("/root/#{filename}")}", tier: 1)
      end

      strings.each_with_index do |str, i|
        filename = filenames[i] || filenames.first
        next if filename.nil?
        first_line = str.to_s.lines.map(&:strip).reject(&:empty?).first
        next if first_line.nil?
        test_local_command("leaked string #{i} is in /root/#{filename}",
                           "cat #{Shellwords.escape("/root/#{filename}")}", first_line)
      end
    end

    tier(2) do
      # The low-privilege account can write the group file, which is the
      # vulnerability, but is not already root or a sudoer.
      test_command_succeeds("#{LOW_PRIV_USER} can write /etc/group", 'test -w /etc/group', user: LOW_PRIV_USER)
      test_local_command("#{LOW_PRIV_USER} is not root", 'id -u', '65534', user: LOW_PRIV_USER)
      out = run_command("getent group sudo | cut -d: -f4")
      if out[:stdout].split(',').map(&:strip).include?(LOW_PRIV_USER)
        fail_check("#{LOW_PRIV_USER} not in sudo group", "#{LOW_PRIV_USER} is already a sudoer, so the test proves nothing", tier: 2)
      else
        pass_check("#{LOW_PRIV_USER} not in sudo group", "#{LOW_PRIV_USER} is not a member of sudo before exploitation", tier: 2)
      end
      # Leaked files must stay root-only, otherwise no escalation is needed.
      filenames.first(1).each do |filename|
        res = run_as_user(LOW_PRIV_USER, "test -r #{Shellwords.escape("/root/#{filename}")}")
        if res[:exit_status] == 0
          fail_check("/root/#{filename} unreadable to #{LOW_PRIV_USER}", "readable without escalation", tier: 2)
        else
          pass_check("/root/#{filename} unreadable to #{LOW_PRIV_USER}", "root-only as intended", tier: 2)
        end
      end
    end

    # Tier 3 is not part of this issue (tier 2 only); no <msf_module> exists for this misconfiguration.
  end
end

WritableGroupsTest.new.run
