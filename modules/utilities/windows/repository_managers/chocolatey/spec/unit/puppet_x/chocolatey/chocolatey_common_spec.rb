require 'spec_helper'
require 'puppet_x/chocolatey/chocolatey_install'
require 'puppet_x/chocolatey/chocolatey_common'

describe 'Chocolatey Common' do

  let (:first_compiled_choco_version) {'0.9.9.0'}
  let (:newer_choco_version) {'0.9.10.0'}
  let (:last_posh_choco_version) {'0.9.8.33'}

  before :each do
    PuppetX::Chocolatey::ChocolateyCommon.stubs(:set_env_chocolateyinstall)
  end

  context ".chocolatey_command" do
    it "should find chocolatey install location based on PuppetX::Chocolatey::ChocolateyInstall", :if => Puppet.features.microsoft_windows? do
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)

      PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command.should == 'c:\dude\bin\choco.exe'
    end

    it "should find chocolatey install location based on default location", :if => Puppet.features.microsoft_windows? do
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('c:\dude\bin\choco.exe').returns(false)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('C:\ProgramData\chocolatey\bin\choco.exe').returns(false)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('C:\Chocolatey\bin\choco.exe').returns(false)

      PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command.should == "#{ENV['ALLUSERSPROFILE']}\\chocolatey\\bin\\choco.exe"
    end
  end

  context ".choco_version" do
    it "should return PuppetX::Chocolatey::ChocolateyVersion.version" do
      expected = '0.9.9.0.1'
      PuppetX::Chocolatey::ChocolateyVersion.expects(:version).returns(expected)
      PuppetX::Chocolatey::ChocolateyCommon.clear_cached_values

      PuppetX::Chocolatey::ChocolateyCommon.choco_version.must eq expected
    end
  end

  context ".choco_config_file" do
    let (:choco_install_loc) { 'c:\dude' }

    it "should return the normal config file location when found" do
      expected = 'c:\dude\config\chocolatey.config'
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(choco_install_loc)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(expected).returns(true)

      PuppetX::Chocolatey::ChocolateyCommon.choco_config_file.must eq expected
    end

    it "should return the old config file location for older installs" do
      expected = 'c:\dude\chocolateyinstall\chocolatey.config'
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(choco_install_loc)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('c:\dude\config\chocolatey.config').returns(false)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(expected).returns(true)

      PuppetX::Chocolatey::ChocolateyCommon.choco_config_file.must eq expected
    end

    it "should return nil when the config cannot be found" do
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(choco_install_loc)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('c:\dude\config\chocolatey.config').returns(false)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with('c:\dude\chocolateyinstall\chocolatey.config').returns(false)

      PuppetX::Chocolatey::ChocolateyCommon.choco_config_file.must be_nil
    end
  end
end
