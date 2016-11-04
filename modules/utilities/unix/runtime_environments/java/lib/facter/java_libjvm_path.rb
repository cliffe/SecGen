# Fact: java_libjvm_path
#
# Purpose: get path to libjvm.so
#
# Resolution:
#   Lists file in java default home and searches for the file
#
# Caveats:
#   Needs to list files recursively. Returns the first match
#
# Notes:
#   None
Facter.add(:java_libjvm_path) do
  confine :kernel => "Linux"
  setcode do
    java_default_home = Facter.value(:java_default_home)
    java_libjvm_file = Dir.glob("#{java_default_home}/jre/lib/**/libjvm.so")
    if java_libjvm_file.nil? || java_libjvm_file.empty?
      nil
    else
      File.dirname(java_libjvm_file[0])
    end
  end
end

