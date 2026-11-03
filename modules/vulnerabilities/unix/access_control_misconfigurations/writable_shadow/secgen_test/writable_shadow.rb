require_relative '../../../../../lib/post_provision_test'

# Inputs (secgen_metadata.xml):
#   strings_to_leak, leaked_filenames: checked below (tier 1), each string must
#   be in a root-only file under /root.
class WritableShadowTest < PostProvisionTest
  SHADOW = '/etc/shadow'.freeze

  def initialize
    self.module_name = 'writable_shadow'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('/etc/shadow is mode 777', "stat -c '%a' #{SHADOW}", '777')
      test_local_command('/etc/shadow is owned by root', "stat -c '%U' #{SHADOW}", 'root')
      check_leaked_strings
    end

    tier(2) do
      # An existing unprivileged account (nobody) can open /etc/shadow for
      # writing, and read it — the point of the vuln (crackable password hashes).
      # The append is empty, so nothing changes and the system is not taken to root.
      test_file_writable(SHADOW, by_low_privilege: true)
      test_command_succeeds('unprivileged user can read /etc/shadow',
                            "head -c1 #{SHADOW} >/dev/null", user: 'nobody')
    end
  end

  private

  # leak_files pairs strings with filenames in order; once the filenames run
  # out, the remaining strings are appended to the first file.
  def check_leaked_strings
    strings   = self.json_inputs['strings_to_leak'] || []
    filenames = self.json_inputs['leaked_filenames'] || []
    return skip_check('leaked strings', 'no strings_to_leak or leaked_filenames supplied') if strings.empty? || filenames.empty?

    # each strings_to_leak[i] must be in /root/leaked_filenames[i] (base class)
    test_leaked_strings(strings, filenames.map { |f| "/root/#{f}" }, tier: 1)
    mode = filenames.uniq.map { |f| Shellwords.escape("/root/#{f}") }.join(' ')
    test_command_succeeds('leaked files are all 0600 root',
                          "[ \"$(stat -c '%a %U' #{mode} | sort -u)\" = '600 root' ]", tier: 1)
  end
end

WritableShadowTest.new.run
