require_relative '../../../../../lib/post_provision_test'

class LimeTest < PostProvisionTest
  def initialize
    self.module_name = 'lime'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # LiME builds a kernel module (.ko) from source at /root/LiME/src
    tier(1) do
      # build prerequisites installed by the Puppet
      %w[git build-essential].each do |pkg|
        test_local_command("#{pkg} installed?", "dpkg -l #{pkg} | grep '^ii'", pkg)
      end
      test_local_command('kernel headers installed?', 'dpkg -l "linux-headers-$(uname -r)" | grep "^ii"', 'linux-headers')
      test_local_command('LiME source cloned?', 'test -d /root/LiME/src && echo "ok"', 'ok')
    end
    tier(2) do
      test_local_command('LiME .ko built?', 'find /root/LiME/src -name "lime-*.ko" 2>/dev/null | head -1', '.ko')
      # the built object is a valid kernel module (modinfo reads it without loading it)
      test_local_command('LiME .ko is a kernel module', 'modinfo $(find /root/LiME/src -name "lime-*.ko" | head -1) 2>&1', 'name:')
    end
  end
end

LimeTest.new.run
