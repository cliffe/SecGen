require_relative '../../../../../lib/post_provision_test'

class NfsRootshareTest < PostProvisionTest
  def initialize
    self.module_name = 'nfs_rootshare'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('nfs-kernel-server installed', 'dpkg -l nfs-kernel-server | grep -E "^ii"', 'nfs-kernel-server')
      test_local_command('/etc/exports configured', 'test -f /etc/exports && cat /etc/exports', '/')
    end
    tier(2) do
      # NFS service exposes the root filesystem (no_root_squash allows root-level access)
      test_local_command('NFS root export visible', 'showmount -e localhost', 'Export list')
      test_local_command('root share with no_root_squash', 'cat /etc/exports', 'no_root_squash')
    end
    # TODO tier 3 (exploit): deferred — mount / from attacker, write authorized_keys as root
  end
end

NfsRootshareTest.new.run
