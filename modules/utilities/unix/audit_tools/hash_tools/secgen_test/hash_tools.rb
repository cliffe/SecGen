require_relative '../../../../../lib/post_provision_test'

class HashToolsTest < PostProvisionTest
  def initialize
    self.module_name = 'hash_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # md5deep on Debian, hashdeep on Kali (md5deep transitional package dropped from kali-rolling)
    tier(1) { test_local_command('md5deep or hashdeep installed?', 'dpkg -l md5deep hashdeep 2>/dev/null | grep "^ii"', 'deep') }
    tier(2) do
      test_local_command('deep-hash tool produces output', '(md5deep /etc/hostname || hashdeep /etc/hostname) 2>&1', '/etc/hostname')
      test_local_command('sha256deep produces output', '(sha256deep /etc/hostname || hashdeep -c sha256 /etc/hostname) 2>&1', '/etc/hostname')
    end

    # debsums is only installed on Debian (not Kali), as in the Puppet
    if run_vagrant_ssh('. /etc/os-release; echo "$ID"')[:stdout].strip == 'debian'
      tier(1) { test_local_command('debsums installed?', 'dpkg -l debsums | grep "^ii"', 'debsums') }
      tier(2) { test_local_command('debsums runs', 'command -v debsums >/dev/null && debsums --help 2>&1', 'debsums') }
    end
  end
end

HashToolsTest.new.run
