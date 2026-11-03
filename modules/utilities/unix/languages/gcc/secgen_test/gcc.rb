require_relative '../../../../../lib/post_provision_test'

class GccTest < PostProvisionTest
  def initialize
    self.module_name = 'gcc'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No read_facts or default inputs: nothing to parameterise.
  def test_module
    super
    tier(1) do
      test_local_command('gcc installed?', 'which gcc', 'gcc')
      test_local_command('build-essential installed?', 'dpkg -l build-essential | grep -E "^ii"', 'build-essential')
      test_local_command('gcc-multilib installed?', 'dpkg -l gcc-multilib | grep -E "^ii"', 'gcc-multilib')
      test_local_command('g++ on PATH', 'which g++', 'g++')
      test_local_command('make on PATH', 'which make', 'make')
    end
    tier(2) do
      test_command_succeeds('gcc version', 'gcc --version')
      test_local_command('make runs as an unprivileged user', 'make --version', 'GNU Make', user: 'nobody')
      # compile and run a real program as an unprivileged user
      build = 'd=$(mktemp -d) && cd $d && printf \'#include <stdio.h>\nint main(){puts("hello-gcc");return 0;}\n\' > h.c'
      test_local_command('gcc compiles and runs a C program', "#{build} && gcc h.c -o h64 && ./h64", 'hello-gcc', user: 'nobody')
      # multilib: 32-bit compile succeeds
      test_command_succeeds('gcc -m32 compiles (multilib)', "#{build} && gcc -m32 h.c -o h32", user: 'nobody')
      test_local_command('g++ compiles and runs a C++ program',
                         'd=$(mktemp -d) && cd $d && printf \'#include <iostream>\nint main(){std::cout<<"hello-gpp"<<std::endl;}\n\' > h.cpp && g++ h.cpp -o hpp && ./hpp',
                         'hello-gpp', user: 'nobody')
    end
  end
end

GccTest.new.run
