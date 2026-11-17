require_relative '../../../../../lib/post_provision_test'

class CrossArchEmulationTest < PostProvisionTest
  # A 130-byte static 32-bit ARM (EABI5) ELF that writes "secgen-arm-ok\n" and exits 0.
  ARM_PROBE_HEX = '7f454c460101010000000000000000000200280001000000540001003400000000000000' \
                  '000000053400200001000000000000000100000000000000000001000000010082000000' \
                  '8200000005000000000001000100a0e314108fe20e20a0e30470a0e3000000ef0000a0e3' \
                  '0170a0e3000000ef73656367656e2d61726d2d6f6b0a'.freeze
  PROBE = '/tmp/secgen_arm_probe'.freeze

  def initialize
    self.module_name = 'cross_arch_emulation'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    user = regular_user || 'nobody'

    tier(1) do
      %w[qemu-user-static binfmt-support gdb-multiarch].each do |pkg|
        test_local_command("#{pkg} package installed?", "dpkg -l #{pkg} | grep '^ii'", pkg)
      end
      test_local_command('qemu-arm registered with binfmt_misc', 'cat /proc/sys/fs/binfmt_misc/qemu-arm 2>&1', 'enabled')
    end

    add_evidence('binfmt formats', 'ls /proc/sys/fs/binfmt_misc/ 2>&1; update-binfmts --display qemu-arm 2>&1')

    tier(2) do
      run_vagrant_ssh("python3 -c \"open('#{PROBE}','wb').write(bytes.fromhex('#{ARM_PROBE_HEX}'))\" && chmod 0755 #{PROBE}")
      test_local_command('ARM binary runs directly', PROBE, 'secgen-arm-ok', user: user)
      test_local_command('gdb-multiarch loads an ARM binary', "gdb-multiarch -batch -ex 'info files' #{PROBE} 2>&1", 'elf32-littlearm')
      run_vagrant_ssh("rm -f #{PROBE}")
    end
  end
end

CrossArchEmulationTest.new.run
