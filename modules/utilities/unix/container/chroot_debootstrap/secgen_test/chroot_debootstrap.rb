require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class ChrootDebootstrapTest < PostProvisionTest
  def initialize
    self.module_name = 'chroot_debootstrap'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # chroot_dir input: where debootstrap installs the system
    chroot_dir = self.json_inputs['chroot_dir']&.first
    skip!('no chroot_dir input') if chroot_dir.nil?
    dir = Shellwords.escape(chroot_dir)

    tier(1) do
      test_local_command('debootstrap installed?', 'which debootstrap', 'debootstrap')
      test_local_command('debootstrap package installed', "dpkg-query -W -f='${Status}' debootstrap", 'install ok installed')
      test_local_command('libc-bin package installed', "dpkg-query -W -f='${Status}' libc-bin", 'install ok installed')
      test_local_command('ldconfig present', 'command -v ldconfig', 'ldconfig')
      # chroot directory and a basic Debian tree should be present after provisioning
      test_local_command('chroot dir exists', "test -d #{dir}/etc && echo ok", 'ok')
      test_local_command('chroot is a Debian tree', "cat #{dir}/etc/debian_version", '12')
      test_local_command('ncat present in chroot', "test -x #{dir}/usr/bin/ncat && echo ok", 'ok')
      test_local_command('chroot /proc mounted via fstab', 'cat /etc/fstab', "proc #{chroot_dir}/proc proc defaults 0 0")
    end
    tier(2) do
      test_command_succeeds('debootstrap runs', 'debootstrap --version')
      test_command_succeeds('ldconfig runs', 'ldconfig -p >/dev/null')
      # commands really execute inside the new root
      test_local_command('chroot identifies as bookworm', "chroot #{dir} /bin/cat /etc/os-release", 'bookworm')
      test_local_command('chroot lists its own root', "chroot #{dir} /bin/ls /", 'usr')
      test_command_succeeds('ncat runs in the chroot', "chroot #{dir} /usr/bin/ncat --version")
      test_local_command('apt works in the chroot', "chroot #{dir} /usr/bin/dpkg -s ncat", 'Status: install ok installed')
    end
  end
end

ChrootDebootstrapTest.new.run
