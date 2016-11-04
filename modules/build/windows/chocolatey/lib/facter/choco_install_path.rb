require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/chocolatey/chocolatey_install'

Facter.add('choco_install_path') do
  setcode do
    PuppetX::Chocolatey::ChocolateyInstall.install_path
  end
end
