require_relative '../../../../../lib/post_provision_test'

class NfsOvershareTest < PostProvisionTest
  def initialize
    self.module_name = 'nfs_overshare'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    storage_dir = self.json_inputs['storage_directory']&.first

    tier(1) do
      test_local_command('nfs-kernel-server installed', 'dpkg -l nfs-kernel-server | grep -E "^ii"', 'nfs-kernel-server')
      if storage_dir
        test_local_command('storage directory exists', "test -d #{storage_dir} && echo ok", 'ok')
        test_local_command('/etc/exports contains storage directory', "grep -F #{storage_dir} /etc/exports", storage_dir)
      else
        test_local_command('/etc/exports configured', 'test -f /etc/exports && cat /etc/exports', '/')
      end
    end

    tier(2) do
      test_local_command('NFS export visible', 'showmount -e localhost', 'Export list')
      if storage_dir
        test_local_command('storage directory exported', "showmount -e localhost", storage_dir)
      end
    end

    if storage_dir
      self.json_inputs['leaked_filenames']&.each do |filename|
        tier(1) { test_local_command("#{filename} present at #{storage_dir}", "test -f #{storage_dir}/#{filename} && echo ok", 'ok') }
      end
    end
    # TODO tier 3 (exploit): deferred — mount share from attacker VM and read leaked files
  end
end

NfsOvershareTest.new.run
