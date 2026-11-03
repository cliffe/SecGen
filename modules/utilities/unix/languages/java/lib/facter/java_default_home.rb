# Fact: java_default_home
#
# Purpose: get absolute path of java system home
#
# Resolution:
#   Find the real java binary, and return the subsubdir
#
# Caveats:
#   java binary has to be found in $PATH
#
# Notes:
#   None
Facter.add(:java_default_home) do
  confine kernel: ['Linux', 'OpenBSD']
  java_default_home = nil
  setcode do
    java_bin = Facter::Util::Resolution.which('java').to_s.strip
    if java_bin.empty?
      nil
    else
      java_path = File.realpath(java_bin)
      java_default_home = if java_path =~ %r{/jre/}
                            File.dirname(File.dirname(File.dirname(java_path)))
                          else
                            File.dirname(File.dirname(java_path))
                          end
    end
  end
  java_default_home
end
