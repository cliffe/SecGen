require 'spec_helper'
require 'puppet_x/chocolatey/chocolatey_version'

describe 'Chocolatey Version' do

  context 'on Windows', :if => Puppet::Util::Platform.windows? do

    context "when Chocolatey is installed" do
      before :each do
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
        File.expects(:exist?).with('c:\dude\bin\choco.exe').returns(true)
      end

      it "should return the value from running choco -v" do
        expected_value = '1.2.3'
        Puppet::Util::Execution.expects(:execute).returns(expected_value)

        PuppetX::Chocolatey::ChocolateyVersion.version.must == expected_value
      end

      it "should handle cleaning up spaces" do
        expected_value = '1.2.3'
        Puppet::Util::Execution.expects(:execute).returns(' ' + expected_value + ' ')

        PuppetX::Chocolatey::ChocolateyVersion.version.must == expected_value
      end

      it "should handle older versions of choco" do
        expected_value = '1.2.3'
        Puppet::Util::Execution.expects(:execute).returns('Please run chocolatey /? or chocolatey help - chocolatey v' + expected_value)

        PuppetX::Chocolatey::ChocolateyVersion.version.must == expected_value
      end

      it "should handle other messages that return with version call" do
        expected_value = '1.2.3'
        Puppet::Util::Execution.expects(:execute).returns("Error setting some value.\nPlease set this value yourself\r\nsound good?\r" + expected_value)

        PuppetX::Chocolatey::ChocolateyVersion.version.must == expected_value
      end

      it "should handle a trailing line break" do
        expected_value = '1.2.3'
        Puppet::Util::Execution.expects(:execute).returns(expected_value + "\r\n")

        PuppetX::Chocolatey::ChocolateyVersion.version.must == expected_value
      end

      it "should handle 0.9.8.33 of choco" do
        expected_value = '1.2.3'
        Puppet::Util::Execution.expects(:execute).returns('!!ATTENTION!!
The next version of Chocolatey (v0.9.9) will require -y to perform
  behaviors that change state without prompting for confirmation. Start
  using it now in your automated scripts.

  For details on the all new Chocolatey, visit http://bit.ly/new_choco
Please run chocolatey /? or chocolatey help - chocolatey v' + expected_value)

        PuppetX::Chocolatey::ChocolateyVersion.version.must == expected_value
      end
    end

    context "When Chocolatey is not installed" do
      before :each do
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(nil)
        File.expects(:exist?).with('\bin\choco.exe').returns(false)
      end

      it "should return nil" do
        PuppetX::Chocolatey::ChocolateyVersion.version.must be_nil
      end
    end

  end

  context 'on Linux', :if => Puppet.features.posix? do
    it "should return nil on a non-windows system" do
      PuppetX::Chocolatey::ChocolateyVersion.version.must be_nil
    end
  end
end
