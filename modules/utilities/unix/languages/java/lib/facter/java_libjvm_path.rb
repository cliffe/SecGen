# Fact: java_libjvm_path
#
# Purpose: get path to libjvm.so
#
# Resolution:
#   Lists file in java default home and searches for the file
#
# Caveats:
#   Needs to list files recursively. Returns the first match
#   Needs working java_major_version fact
#
# Notes:
#   None
Facter.add(:java_libjvm_path) do
  confine kernel: ['Linux', 'OpenBSD']
  setcode do
    java_default_home = Facter.value(:java_default_home)
    java_major_version = Facter.value(:java_major_version)
    unless java_major_version.nil?
      java_libjvm_file = if java_major_version.to_i >= 11
                           Dir.glob("#{java_default_home}/lib/**/libjvm.so")
                         else
                           Dir.glob("#{java_default_home}/jre/lib/**/libjvm.so")
                         end
      if java_libjvm_file.nil? || java_libjvm_file.empty?
        nil
      else
        File.dirname(java_libjvm_file[0])
      end
    end
  end
end
