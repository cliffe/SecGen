# Fact: gemhome
#
# Purpose: Returns the gem home for rubygems
#
# Resolution: Returns GEM_HOME.
#
# Caveats:
#
begin
  require 'rubygems'

  Facter.add(:gemhome) do
    setcode { Gem::dir }
  end
rescue LoadError
end
