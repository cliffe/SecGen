require_relative '../../../../../lib/post_provision_test'

class JavaDecompileTest < PostProvisionTest
  def initialize
    self.module_name = 'java_decompile'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # A .class file is compiled and placed in a challenge directory under the user's home.
      test_local_command('java .class file placed', 'find /home /root -name "*.class" | head -1', '.class')
    end
    tier(2) do
      # Java .class files start with the magic bytes CA FE BA BE.
      # od (coreutils) prints the bytes the same way everywhere; xxd's grouping differs
      # between versions (ca fe ba be vs cafe babe) and xxd isn't always installed.
      test_local_command('valid Java class magic bytes', 'find /home /root -name "*.class" | head -1 | xargs -I{} od -An -tx1 -N4 "{}" 2>/dev/null | tr -d " \\n"', 'cafebabe')
    end
    # TODO tier 3 (exploit): deferred — challenge is a CTF reverse-engineering task, no remote exploit
  end
end

JavaDecompileTest.new.run
