require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_install_path fact' do
  subject(:fact) { Facter.fact(:choco_install_path) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  context "on Windows", :if => Puppet::Util::Platform.windows? do
    it "should return the output of PuppetX::Chocolatey::ChocolateyInstall.install_path" do
      expected_value = 'C:\somewhere'
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(expected_value)

      subject.value.must == expected_value
    end

    it "should return the default path when PuppetX::Chocolatey::ChocolateyInstall.install_path is nil" do
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(nil)

      subject.value.must == 'C:\ProgramData\chocolatey'
    end
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
