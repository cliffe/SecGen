# Fact: java_patch_level
#
# Purpose: get Java's patch level
#
# Resolution:
#   Uses java_version fact splits on the patch number (after _)
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:java_patch_level) do
  java_patch_level = nil
  setcode do
    java_version = Facter.value(:java_version)
    java_patch_level = java_version.strip.split('_')[1] unless java_version.nil?
  end
  java_patch_level
end
