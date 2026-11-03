require_relative '../../../../../lib/post_provision_test'

class GnuscreenTest < PostProvisionTest
  SCREEN = '/usr/local/bin/screen-4.5.0'.freeze

  def initialize
    self.module_name = 'gnuscreen'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    leaked = Array(self.json_inputs['leaked_filenames']).map(&:to_s).reject(&:empty?)
    tier(1) do
      # install.pp builds screen 4.5.0 from source; its make install sets the setuid bit
      test_local_command('screen 4.5.0 setuid root', "stat -c '%U %a' #{SCREEN}", 'root 4755')
      test_local_command('screen links to 4.5.0', 'readlink /usr/local/bin/screen', 'screen-4.5.0')
      leaked.each do |f|
        test_local_command("#{f} root-only in /root", "stat -c '%U:%G %a' #{Shellwords.escape("/root/#{f}")}", 'root:root 600')
      end
    end
    tier(2) do
      # the vulnerable version is what an unprivileged user finds and can run
      test_local_command('unprivileged user runs screen 4.05.00', "#{SCREEN} -v", '4.05.00', user: 'nobody')
    end
    # No tier 3: CVE-2017-5618 is a local privesc with no Metasploit module in this batch
  end
end

GnuscreenTest.new.run
