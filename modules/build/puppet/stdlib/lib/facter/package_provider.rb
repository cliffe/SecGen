# Fact: package_provider
#
# Purpose: Returns the default provider Puppet will choose to manage packages
#   on this system
#
# Resolution: Instantiates a dummy package resource and return the provider
#
# Caveats:
#
require 'puppet/type'
require 'puppet/type/package'

Facter.add(:package_provider) do
  setcode do
    if defined? Gem and Gem::Version.new(Facter.value(:puppetversion).split(' ')[0]) >= Gem::Version.new('3.6')
      Puppet::Type.type(:package).newpackage(:name => 'dummy', :allow_virtual => 'true')[:provider].to_s
    else
      Puppet::Type.type(:package).newpackage(:name => 'dummy')[:provider].to_s
    end
  end
end
