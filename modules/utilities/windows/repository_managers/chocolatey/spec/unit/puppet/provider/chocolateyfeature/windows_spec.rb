require 'spec_helper'
require 'stringio'
require 'puppet/type/chocolateyfeature'
require 'puppet/provider/chocolateyfeature/windows'
require 'rexml/document'

provider = Puppet::Type.type(:chocolateyfeature).provider(:windows)
describe provider do
  let (:name) { 'allowglobalconfirmation' }
  let (:resource) { Puppet::Type.type(:chocolateyfeature).new(:provider => :windows, :name => name, :ensure => 'enabled' ) }
  let (:choco_config) { 'c:\choco.config' }
  let (:choco_install_path) { 'c:\dude\bin\choco.exe' }
  let (:choco_config_contents) { <<-'EOT'
<?xml version="1.0" encoding="utf-8"?>
<chocolatey xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <config>
    <add key="cacheLocation" value="" description="Cache location if not TEMP folder." />
    <add key="commandExecutionTimeoutSeconds" value="2700" description="Default timeout for command execution." />
    <add key="containsLegacyPackageInstalls" value="true" description="Install has packages installed prior to 0.9.9 series." />
    <add key="proxy" value="" description="Explicit proxy location." />
    <add key="proxyUser" value="" description="Optional proxy user." />
    <add key="proxyPassword" value="" description="Optional proxy password. Encrypted." />
    <add key="virusCheckMinimumPositives" value="5" description="Minimum numer of scan result positives before flagging a binary as a possible virus. Available in 0.9.10+. Licensed versions only." />
    <add key="virusScannerType" value="VirusTotal" description="Virus Scanner Type (Generic or VirusTotal). Defaults to VirusTotal for Pro. Available in 0.9.10+. Licensed versions only." />
    <add key="genericVirusScannerPath" value="" description="The full path to the command line virus scanner executable. Used when virusScannerType is Generic. Available in 0.9.10+. Licensed versions only." />
    <add key="genericVirusScannerArgs" value="[[File]]" description="The arguments to pass to the generic virus scanner. Use [[File]] for the file path placeholder. Used when virusScannerType is Generic. Available in 0.9.10+. Licensed versions only." />
    <add key="genericVirusScannerValidExitCodes" value="0" description="The exit codes for the generic virus scanner when a file is not flagged. Separate with comma, defaults to 0. Used when virusScannerType is Generic. Available in 0.9.10+. Licensed versions only." />
  </config>
  <sources>
    <source id="local" value="c:\packages" disabled="true" user="rob" password="bogus\/encrypted+value=" priority="0" />
    <source id="chocolatey" value="https://chocolatey.org/api/v2/" disabled="false" priority="0" />
    <source id="chocolatey.licensed" value="https://licensedpackages.chocolatey.org/api/v2/" disabled="false" user="customer" password="bogus/encrypted+value=" priority="10" />
  </sources>
  <features>
    <feature name="checksumFiles" enabled="true" setExplicitly="false" description="Checksum files when pulled in from internet (based on package)." />
    <feature name="virusCheckFiles" enabled="false" setExplicitly="false" />
    <feature name="autoUninstaller" enabled="true" setExplicitly="true" description="Uninstall from programs and features without requiring an explicit uninstall script." />
    <feature name="allowGlobalConfirmation" enabled="false" setExplicitly="true" description="Prompt for confirmation in scripts or bypass." />
    <feature name="allowInsecureConfirmation" enabled="false" setExplicitly="false" />
    <feature name="failOnAutoUninstaller" enabled="false" setExplicitly="false" description="Fail if automatic uninstaller fails." />
    <feature name="failOnStandardError" enabled="false" setExplicitly="false" description="Fail if install provider writes to stderr." />
    <feature name="powershellHost" enabled="true" setExplicitly="false" description="Use Chocolatey''s built-in PowerShell host." />
    <feature name="logEnvironmentValues" enabled="false" setExplicitly="false" description="Log Environment Values - will log values of environment before and after install (could disclose sensitive data)." />
    <feature name="virusCheck" enabled="true" setExplicitly="true" description="Virus Check - perform virus checking on downloaded files. Available in 0.9.10+. Licensed versions only." />
    <feature name="downloadCache" enabled="true" setExplicitly="false" description="Download Cache - use the private download cache if available for a package. Available in 0.9.10+. Licensed versions only." />
    <feature name="failOnInvalidOrMissingLicense" enabled="false" setExplicitly="false" description="Fail On Invalid Or Missing License - allows knowing when a license is expired or not applied to a machine." />
    <feature name="ignoreInvalidOptionsSwitches" enabled="true" setExplicitly="false" description="Ignore Invalid Options/Switches - If a switch or option is passed that is not recognized, should choco fail?" />
    <feature name="usePackageExitCodes" enabled="true" setExplicitly="false" description="Use Package Exit Codes - Package scripts can provide exit codes. With this on, package exit codes will be what choco uses for exit when non-zero (this value can come from a dependency package). Chocolatey defines valid exit codes as 0, 1605, 1614, 1641, 3010. With this feature off, choco will exit with a 0 or a 1 (matching previous behavior). Available in 0.9.10+." />
  </features>
  <apiKeys>
    <apiKeys source="https:\/\/chocolatey.org\/" key="bogus\/encrypted+value=" />
 </apiKeys>
</chocolatey>
  EOT
  }

  let (:minimum_supported_version) {'0.9.9.0'}

  before :each do
    PuppetX::Chocolatey::ChocolateyInstall.stubs(:install_path).returns('c:\dude')
    PuppetX::Chocolatey::ChocolateyCommon.stubs(:choco_version).returns(minimum_supported_version)

    @provider = provider.new(resource)
    resource.provider = @provider

    # Stub all file and config tests
    provider.stubs(:healthcheck)
  end

  context "verify provider" do
    it "should be an instance of Puppet::Type::Chocolateyfeature::ProviderWindows" do

      @provider.must be_an_instance_of Puppet::Type::Chocolateyfeature::ProviderWindows
    end

    it "should have a enable method" do
      @provider.should respond_to(:enable)
    end

    it "should have an exists? method" do
      @provider.should respond_to(:exists?)
    end

    it "should have a disable method" do
      @provider.should respond_to(:disable)
    end

    it "should have a properties method" do
      @provider.should respond_to(:properties)
    end

    it "should have a query method" do
      @provider.should respond_to(:query)
    end
  end

  context "self.get_features" do
    before :each do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
    end

    it "should error when the config file location is null" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(nil)

      expect {
        provider.get_features
      }.to raise_error(Puppet::ResourceError, /Config file not found for Chocolatey/)
    end

    it "should error when the config file is not found" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(false)

      expect {
        provider.get_features
      }.to raise_error(Puppet::ResourceError, /was unable to locate config file at/)
    end

    context "when getting features from the config file" do
      features = []

      before :each do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
        File.expects(:new).with(choco_config,"r").returns choco_config_contents

        features = provider.get_features
      end

      it "should match the count of features in the config" do
        features.count.must eq 14

      end

      it "should contain xml elements" do
        features[0].must be_an_instance_of REXML::Element
      end
    end
  end

  context "self.get_feature" do
    let (:element) {  REXML::Element.new('feature') }
    element_name = "default"
    element_enabled = 'true'

    before :each do
      element.add_attributes( { "name" => element_name, "enabled" => element_enabled, } )
    end

    it "should return nil feature when element is nil" do
      provider.get_feature(nil).must be == {}
    end

    it "should convert an element to a feature" do
      feature = provider.get_feature(element)

      feature[:name].must eq element_name
      feature[:ensure].must eq :enabled
    end

    it "when feature is disabled" do
      element.delete_attribute('enabled')
      element.add_attribute('enabled', 'false')

      feature = provider.get_feature(element)
      feature[:ensure].must eq :disabled
    end
  end

end
