# Fact: java_major_version
#
# Purpose: get Java's major version
#
# Resolution:
#   Tests for presence of java, returns nil if not present
#   returns output of "java -version" and splits on \n + '"'
#   eg.
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:java_major_version) do
  java_major_version = nil
  setcode do
    java_version = Facter.value(:java_version)
    unless java_version.nil?
      java_major_version = if java_version.strip[0..1] == '1.'
                             java_version.strip.split('_')[0].split('.')[1]
                           else
                             java_version.strip.split('.')[0]
                           end
    end
  end
  java_major_version
end
