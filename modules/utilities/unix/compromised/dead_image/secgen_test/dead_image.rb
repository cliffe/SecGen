require_relative '../../../../../lib/post_provision_test'

class DeadImageTest < PostProvisionTest
  # No inputs: the image and md5s are fetched from a fixed URL into /root/evidence.
  def initialize
    self.module_name = 'dead_image'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('evidence directory exists', 'test -d /root/evidence && echo /root/evidence', '/root/evidence')
      test_local_command('disk image present', 'test -f /root/evidence/hda1.img && echo /root/evidence/hda1.img', '/root/evidence/hda1.img')
      test_local_command('md5s file present', 'test -f /root/evidence/md5s && echo /root/evidence/md5s', '/root/evidence/md5s')
    end
    tier(2) do
      # Image file must be non-empty (it is fetched from a remote URL at provision time)
      test_command_succeeds('disk image non-empty', 'test -s /root/evidence/hda1.img')
      test_command_succeeds('md5s non-empty', 'test -s /root/evidence/md5s')
      # the image is a real disk image, not an error page: readable and over 1 MiB
      test_command_succeeds('disk image is large', 'test "$(stat -c %s /root/evidence/hda1.img)" -gt 1048576')
      test_local_command('disk image first sector readable', 'dd if=/root/evidence/hda1.img bs=512 count=1 2>/dev/null | wc -c', '512')
      # md5s lists hashes
      test_command_succeeds('md5s contains an md5 hash', 'grep -Eq "[0-9a-f]{32}" /root/evidence/md5s')
    end
  end
end

DeadImageTest.new.run
