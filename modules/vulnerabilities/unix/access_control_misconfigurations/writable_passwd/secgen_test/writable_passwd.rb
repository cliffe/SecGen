require_relative '../../../../../lib/post_provision_test'

# Inputs (secgen_metadata.xml):
#   strings_to_leak, leaked_filenames: checked below (tier 1), each string must
#   be in a root-only file under /root.
class WritablePasswdTest < PostProvisionTest
  PASSWD = '/etc/passwd'.freeze

  def initialize
    self.module_name = 'writable_passwd'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('/etc/passwd is mode 777', "stat -c '%a' #{PASSWD}", '777')
      test_local_command('/etc/passwd is owned by root', "stat -c '%U' #{PASSWD}", 'root')
      check_leaked_strings
    end

    tier(2) do
      # An existing unprivileged account (nobody) can open /etc/passwd for
      # writing. No account is created: useradd rewrites /etc/passwd, which could
      # change the mode we are observing. The append is empty, so nothing changes
      # and the system is not taken to root.
      test_file_writable(PASSWD, by_low_privilege: true)
      # The flag files stay protected: the user needs the vulnerability to reach them.
      (self.json_inputs['leaked_filenames'] || []).uniq.each do |f|
        test_command_succeeds("unprivileged user cannot read /root/#{f}",
                              "! cat #{Shellwords.escape("/root/#{f}")} >/dev/null 2>&1", user: 'nobody')
      end
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

WritablePasswdTest.new.run
