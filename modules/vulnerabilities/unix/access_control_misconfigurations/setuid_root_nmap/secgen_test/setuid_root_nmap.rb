require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class SetuidRootNmapTest < PostProvisionTest
  def initialize
    self.module_name = 'setuid_root_nmap'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: strings_to_leak and leaked_filenames are both checked below.
  # Each string is paired with the filename at the same index; surplus strings
  # are appended to the first file (see secgen_functions::leak_files).
  def test_module
    super
    names   = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)

    tier(1) do
      test_local_command('nmap is setuid root', "stat -c '%U %a' /usr/bin/nmap", 'root 4755')

      strings.each_with_index do |str, i|
        file = names[i] || names.first
        next if file.nil?
        path = Shellwords.escape("/root/#{file}")
        test_local_command("#{file} is root-only in /root", "stat -c '%U:%G %a' #{path}", 'root:root 600')
        first_line = str.lines.first.to_s.strip
        next if first_line.empty?
        test_local_command("#{file} holds leaked string #{i + 1}", "grep -F -- #{Shellwords.escape(first_line)} #{path}", first_line)
      end
    end

    tier(2) do
      # A SYN scan needs raw sockets, so nmap only succeeds for an unprivileged
      # user when the setuid bit gives it euid 0. Without the bit it exits 1
      # ("requires root privileges").
      test_command_succeeds('unprivileged user runs a raw-socket scan through setuid nmap',
                            'nmap -sS -n -Pn -p 22 127.0.0.1', user: 'nobody')
    end
    # Tier 3 (nmap --script / interactive escape to a root shell) is out of scope for this issue.
  end

end

SetuidRootNmapTest.new.run
