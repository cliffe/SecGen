require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/chocolatey/chocolatey_install'

Facter.add('choco_install_path') do
  confine :osfamily => :windows
  setcode do
    PuppetX::Chocolatey::ChocolateyInstall.install_path || 'C:\ProgramData\chocolatey'
  end
end
