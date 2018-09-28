require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_version'

describe 'chocolateyversion fact' do
  subject(:fact) { Facter.fact(:chocolateyversion) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  context "on Windows", :if => Puppet::Util::Platform.windows? do
    it "should return the output of PuppetX::Chocolatey::ChocolateyVersion.version" do
      expected_value = '1.2.3'
      PuppetX::Chocolatey::ChocolateyVersion.expects(:version).returns(expected_value)

      subject.value.must == expected_value
    end

    it "should return the default of 0 when PuppetX::Chocolatey::ChocolateyVersion.version is nil" do
      PuppetX::Chocolatey::ChocolateyVersion.expects(:version).returns(nil)

      subject.value.must == '0'
    end
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
