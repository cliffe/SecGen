require_relative '../../../../../lib/post_provision_test'
require 'json'

class QemuKvmDevboxTest < PostProvisionTest
  def initialize
    self.module_name = 'qemu_kvm_devbox'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('Tools installed', 'command -v qemu-system-x86_64 qemu-img virsh virt-install ruby git gcc cloud-localds', 'virt-install')
      test_command_succeeds('Cloud image present and valid', 'qemu-img check /var/lib/devbox/images/debian-12-generic-amd64.qcow2')
    end

    accounts = (self.json_inputs['accounts'] || []).map { |account| JSON.parse(account)['username'] }
    accounts.each do |username|
      tier(1) { test_local_command("#{username} in kvm and libvirt groups", "id -nG #{username} | tr ' ' '\\n' | grep -E '^(kvm|libvirt)$' | sort | tr '\\n' ' '", 'kvm libvirt') }
      # Run as the account: proves group access, nested KVM, and the QMP hot-plug lifecycle.
      tier(2) { test_command_succeeds("KVM and QMP work for #{username}", 'devbox-check', user: username) }
    end

    tier(2) { test_command_succeeds('libvirt running', 'systemctl is-active libvirtd') }
    add_evidence('cpu_virtualisation_flags', "grep -c -E 'vmx|svm' /proc/cpuinfo; ls -l /dev/kvm; lsblk; df -h /")
  end
end

QemuKvmDevboxTest.new.run
