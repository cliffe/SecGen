require_relative '../../../../../lib/post_provision_test'

class NFSShareTest < PostProvisionTest
  def initialize
    self.module_name = 'nfs_share'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 2049 # NFS is fixed at 2049; the module has no port input
  end

  def test_module
    super
    dirs = self.json_inputs['storage_directory'] || []
    tier(1) do
      test_command_succeeds('nfs-kernel-server installed', 'dpkg -s nfs-kernel-server', tier: 1)
      test_local_command('exports file', 'cat /etc/exports', 'no_subtree_check')
      # each configured storage directory exists and is listed in /etc/exports
      test_command_succeeds('nfs-common installed', 'dpkg -s nfs-common', tier: 1)
      test_command_succeeds('rpcbind installed', 'dpkg -s rpcbind', tier: 1)
      test_command_succeeds('wheel group exists', 'getent group wheel', tier: 1)
      dirs.each do |dir|
        test_local_command("#{dir} owner, group and mode", "stat -c '%U:%G %a' #{dir}", 'root:wheel 754')
        test_command_succeeds("#{dir} exists", "test -d #{dir}", tier: 1)
        test_local_command("#{dir} in exports", 'cat /etc/exports', dir)
      end
    end
    # Tier 2: NFS server listening and the exports are active
    tier(2) do
      test_service_up
      test_local_command('active export', 'exportfs -v', 'no_subtree_check')
      test_local_command('rpcbind lists nfs', 'rpcinfo -p localhost', 'nfs')
      dirs.each { |dir| test_local_command("#{dir} visible to showmount", 'showmount -e localhost', dir) }
      dirs.each { |dir| test_local_command("#{dir} actively exported", 'exportfs -v', dir) }
    end
  end
end

NFSShareTest.new.run
