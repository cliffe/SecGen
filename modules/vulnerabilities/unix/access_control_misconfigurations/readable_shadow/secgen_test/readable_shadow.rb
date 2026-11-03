require_relative '../../../../../lib/post_provision_test'


class ReadableShadowTest < PostProvisionTest
  def initialize
    self.module_name = 'readable_shadow'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs checked: strings_to_leak and leaked_filenames (root-only files in /root).
  # The module has no account or port input. Unprivileged probe account: nobody
  # (exists on every base, not in the shadow group).
  def test_module
    super
    strings = Array(self.json_inputs['strings_to_leak']).map(&:to_s)
    files   = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)

    tier(1) do
      test_local_command('/etc/shadow is world-readable', "stat -c '%U %a' /etc/shadow", 'root 644')

      # leak_files pairs strings with filenames; extra strings are appended to the first file
      files.each_with_index do |f, i|
        path = Shellwords.escape("/root/#{f}")
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{path}", 'root:root 600')
        expected = (strings[i] || '').lines.first.to_s.strip
        test_local_command("#{f} holds its leaked string", "cat #{path}", expected) unless expected.empty?
      end
    end

    tier(2) do
      # the misconfiguration as the attacker sees it: a low-privilege account reads the hashes
      test_command_succeeds('unprivileged user can read /etc/shadow', 'cat /etc/shadow > /dev/null', user: 'nobody')
      test_local_command('unprivileged user sees the root entry in /etc/shadow',
                         'grep "^root:" /etc/shadow', 'root:', user: 'nobody')
      # a real hash (e.g. $y$ or $6$) rather than an empty or locked field
      test_command_succeeds('root entry holds a password hash',
                            "grep -E '^root:[$][^:]{10,}:' /etc/shadow", user: 'nobody')
      # the leaked files stay out of reach, so the shadow file is the way in
      files.first(1).each do |f|
        test_local_command('root-only file is unreadable to the same user',
                           "cat #{Shellwords.escape("/root/#{f}")} 2>&1", 'Permission denied', user: 'nobody')
      end
    end
    # No tier 3: out of scope for this issue (tier 2 only).
  end

end

ReadableShadowTest.new.run
