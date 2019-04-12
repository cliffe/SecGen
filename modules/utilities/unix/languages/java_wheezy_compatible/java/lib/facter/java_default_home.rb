# Fact: java_default_home
#
# Purpose: get absolute path of java system home
#
# Resolution:
#   Uses `readlink` to resolve the path of `/usr/bin/java` then returns subsubdir
#
# Caveats:
#   Requires readlink
#
# Notes:
#   None
Facter.add(:java_default_home) do
  confine :kernel => 'Linux'
  setcode do
    if Facter::Util::Resolution.which('readlink')
      java_bin = Facter::Util::Resolution.exec('readlink -e /usr/bin/java').strip
      java_default_home = File.dirname(File.dirname(File.dirname(java_bin)))
    end
  end
end
