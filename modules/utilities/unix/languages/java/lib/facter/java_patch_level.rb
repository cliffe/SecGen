# Fact: java_patch_level
#
# Purpose: get Java's patch level
#
# Resolution:
#   Uses java_version fact splits on the patch number (after _ for 1.x and patch number for semver'ed javas)
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
    unless java_version.nil?
      if java_version.strip[0..1] == '1.'
        java_patch_level = java_version.strip.split('_')[1] unless java_version.nil?
      else
        java_patch_level = java_version.strip.split('.')[2] unless java_version.nil?
      end
    end
  end
  java_patch_level
end
