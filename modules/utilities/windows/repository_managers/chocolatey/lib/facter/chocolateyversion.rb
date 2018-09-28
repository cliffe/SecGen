require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/chocolatey/chocolatey_version'

Facter.add('chocolateyversion') do
  confine :osfamily => :windows
  setcode do
    PuppetX::Chocolatey::ChocolateyVersion.version || '0'
  end
end
