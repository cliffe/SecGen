require_relative '../../../../../lib/post_provision_test'

class KaliFuzzingTest < PostProvisionTest
  def initialize
    self.module_name = 'kali_fuzzing'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # No inputs.
    tier(1) do
      test_local_command('kali-tools-fuzzing installed', 'dpkg -l kali-tools-fuzzing | grep -E "^ii"', 'kali-tools-fuzzing')
      test_local_command('ncat installed', 'dpkg -l ncat | grep -E "^ii"', 'ncat')
      test_local_command('libc6-dev-i386 installed', 'dpkg -l libc6-dev-i386 | grep -E "^ii"', 'libc6-dev-i386')
      test_local_command('ncat on PATH', 'which ncat', 'ncat')
    end
    tier(2) do
      test_command_succeeds('ncat available', 'ncat --version')
      # ncat moves data over loopback: listener on one end, client on the other
      test_local_command('ncat transfers data',
                         '(ncat -l 127.0.0.1 45454 > /tmp/ncat_test.out &) ; sleep 1; echo ncat_ok | ncat -w 2 127.0.0.1 45454; sleep 1; cat /tmp/ncat_test.out; pkill -f "ncat -l 127.0.0.1 45454"; rm -f /tmp/ncat_test.out',
                         'ncat_ok')
      # 32-bit compile works (libc6-dev-i386), when a compiler is on the box
      if run_command('command -v gcc')[:exit_status] == 0
        test_command_succeeds('gcc -m32 compiles and runs',
                              "echo 'int main(void){return 0;}' | gcc -m32 -x c - -o /tmp/t32 && /tmp/t32; r=$?; rm -f /tmp/t32; exit $r")
      else
        skip_check('gcc -m32 compiles and runs', 'gcc is not installed', tier: 2)
      end
    end
  end
end

KaliFuzzingTest.new.run
