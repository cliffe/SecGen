require_relative '../../../../../lib/post_provision_test'

class JavaTest < PostProvisionTest
  def initialize
    self.module_name = 'java'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No read_facts or default inputs: nothing to parameterise. java.pp installs
  # the default 'jdk' distribution, so both java and javac are expected.
  def test_module
    super
    tier(1) do
      test_local_command('java binary on PATH?', 'which java', 'java')
      test_local_command('javac binary on PATH (JDK installed)?', 'which javac', 'javac')
      test_local_command('OpenJDK JDK package installed?', "dpkg -l | grep -E '^ii +openjdk-[0-9]+-jdk'", 'openjdk')
      test_local_command('java alternative resolves into a JVM directory', 'readlink -f $(which java)', '/jvm/')
    end
    tier(2) do
      test_command_succeeds('java version', 'java -version')
      test_command_succeeds('java runs as an unprivileged user', 'java -version', user: 'nobody')
      test_command_succeeds('javac version', 'javac -version')
      test_local_command('javac compiles and java runs a program',
                         'd=$(mktemp -d) && cd $d && printf \'public class Hello { public static void main(String[] a) { System.out.println("hello-java"); } }\n\' > Hello.java && javac Hello.java && java Hello',
                         'hello-java', user: 'nobody')
    end
  end
end

JavaTest.new.run
