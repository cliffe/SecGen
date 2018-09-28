#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet_x/puppetlabs/powershell/powershell_version'
require 'puppet_x/puppetlabs/powershell/compatible_powershell_version'

describe PuppetX::PuppetLabs::PowerShell::CompatiblePowerShellVersion, :if => Puppet::Util::Platform.windows? do
  before(:each) do
    @compat = PuppetX::PuppetLabs::PowerShell::CompatiblePowerShellVersion
  end

  describe "when a newer version of PowerShell is installed" do
    it "should return true when PowerShell v3 is installed" do
      PuppetX::PuppetLabs::PowerShell::PowerShellVersion.expects(:version).returns('3.0')

      expect(@compat.compatible_version?).to eq(true)
    end

     it "should return true when PowerShell v5.0 is installed" do
      PuppetX::PuppetLabs::PowerShell::PowerShellVersion.expects(:version).returns('5.0.201001.1')

      expect(@compat.compatible_version?).to eq(true)
    end
  end

  describe "when PowerShell v2 is installed" do
    before(:each) do
      PuppetX::PuppetLabs::PowerShell::PowerShellVersion.expects(:version).returns('2.0')
    end

    it "should return true when .NET 3.5 is installed" do
      reg_key = mock('bob')
      Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5', Win32::Registry::KEY_READ | 0x100).yields(reg_key)

      expect(@compat.compatible_version?).to eq(true)
    end

    it "should return false when .NET 3.5 is not installed" do
      Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once

      expect(@compat.compatible_version?).to eq(false)
    end
  end

  describe "when PowerShell is not installed or not compatible" do
    it "should return false when PowerShell is not installed" do
      PuppetX::PuppetLabs::PowerShell::PowerShellVersion.expects(:version).returns(nil)

      expect(@compat.compatible_version?).to eq(false)
    end

    it "should return false when PowerShell is v1" do
      PuppetX::PuppetLabs::PowerShell::PowerShellVersion.expects(:version).returns('1.0')

      expect(@compat.compatible_version?).to eq(false)
    end
  end
end
