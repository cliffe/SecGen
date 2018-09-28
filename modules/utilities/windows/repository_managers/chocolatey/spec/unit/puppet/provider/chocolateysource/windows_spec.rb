require 'spec_helper'
require 'stringio'
require 'puppet/type/chocolateysource'
require 'puppet/provider/chocolateysource/windows'
require 'rexml/document'

provider = Puppet::Type.type(:chocolateysource).provider(:windows)
describe provider do
  let (:name) { 'sourcename' }
  let (:location) { 'c:\packages' }
  let (:resource) { Puppet::Type.type(:chocolateysource).new(:provider => :windows, :name => name, :location => location) }
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
    <source id="local" value="c:\packages" disabled="true" user="rob" password="bogus/encrypted+value=" priority="0" />
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
    <apiKeys source="https://chocolatey.org/" key="bogus/encrypted+value=" />
 </apiKeys>
</chocolatey>
  EOT
  }

  let (:newer_choco_version) {'0.9.10.0'}
  let (:minimum_supported_version_priority) {'0.9.9.9'}
  let (:last_unsupported_version_priority) {'0.9.9.8'}
  let (:minimum_supported_version) {'0.9.9.0'}
  let (:last_unsupported_version) {'0.9.8.33'}

  before :each do
    PuppetX::Chocolatey::ChocolateyInstall.stubs(:install_path).returns('c:\dude')
    PuppetX::Chocolatey::ChocolateyCommon.stubs(:choco_version).returns(minimum_supported_version)

    @provider = provider.new(resource)
    resource.provider = @provider

    # Stub all file and config tests
    provider.stubs(:healthcheck)
  end

  context "verify provider" do
    it "should be an instance of Puppet::Type::Chocolateysource::ProviderWindows" do

      @provider.must be_an_instance_of Puppet::Type::Chocolateysource::ProviderWindows
    end

    it "should have a create method" do
      @provider.should respond_to(:create)
    end

    it "should have an exists? method" do
      @provider.should respond_to(:exists?)
    end

    it "should have a disable method" do
      @provider.should respond_to(:disable)
    end

    it "should have a destroy method" do
      @provider.should respond_to(:destroy)
    end

    it "should have a properties method" do
      @provider.should respond_to(:properties)
    end

    it "should have a query method" do
      @provider.should respond_to(:query)
    end
  end

  context "properties" do

    context ":location" do
      it "should accept c:\\packages" do
        resource[:location] = 'c:\packages'
      end

      it "should accept http://somelocation/packages" do
        resource[:location] = 'http://somelocation/packages'
      end

      it "should accept \\\\unc\\share\\packages" do
        resource[:location] = '\\unc\share\packages'
      end
    end

    context ":user" do
      it "should accept 'bob'" do
        resource[:user] = 'bob'
      end

      it "should accept 'domain\\bob'" do
        resource[:user] = 'domain\bob'
      end

      it "should accept api keys like 'api123-456-243 d123'" do
        resource[:user] = 'api123-456-243 d123'
      end
    end

    context ":password" do
      it "should accept 'bob'" do
        resource[:password] = 'bob'
      end

      it "should accept api keys like 'api123-456-243 d123'" do
        resource[:password] = 'api123-456-243 d123'
      end
    end
  end

  context "self.get_sources" do
    before :each do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
    end

    it "should error when the config file location is null" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(nil)

      expect {
        provider.get_sources
      }.to raise_error(Puppet::ResourceError, /Config file not found for Chocolatey/)
    end

    it "should error when the config file is not found" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(false)

      expect {
        provider.get_sources
      }.to raise_error(Puppet::ResourceError, /was unable to locate config file at/)
    end

    context "when getting sources from the config file" do
      sources = []

      before :each do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
        File.expects(:new).with(choco_config,"r").returns choco_config_contents

        sources = provider.get_sources
      end

      it "should match the count of sources in the config" do
        sources.count.must eq 3

      end

      it "should contain xml elements" do
        sources[0].must be_an_instance_of REXML::Element
      end
    end
  end

  context "self.get_source" do
    let (:element) {  REXML::Element.new('source') }
    element_id = "default"
    element_value= "c:\\packages"
    element_disabled = "false"
    element_priority = "10"
    element_user = "thisguy"
    element_password = "super/encrypted+value=="


    before :each do
      element.add_attributes( { "id"        => element_id,
                                "value"     => element_value,
                                "disabled"  => element_disabled,
                                "priority"  => element_priority,
                                "user"      => element_user,
                                "password"  => element_password
                              } )
    end

    it "should return nil source when element it nil" do
      provider.get_source(nil).must be == {}
    end

    it "should convert an element to a source" do
      source = provider.get_source(element)

      source[:name].must eq element_id
      source[:location].must eq element_value
      source[:priority].must eq element_priority
      source[:user].must eq element_user
      source[:ensure].must eq :present
    end

    it "should convert a bare bones element to a source" do
      element.delete_attribute('disabled')
      element.delete_attribute('priority')
      element.delete_attribute('user')
      element.delete_attribute('password')

      source = provider.get_source(element)

      source[:name].must eq element_id
      source[:location].must eq element_value
      source[:ensure].must eq :present
    end

    it "when source is disabled" do
      element.delete_attribute('disabled')
      element.add_attribute('disabled', 'true')

      source = provider.get_source(element)
      source[:ensure].must eq :disabled
    end
  end

  context ".validation" do
    before :each do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).returns(true).at_least(0)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_install_path).returns(true).at_least(0)
    end

    it "should not warn when both user/password are empty" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_version)
      Puppet.expects(:warning).never
      Puppet.expects(:debug).never

      resource.provider.validate
    end

    it "should throw when choco version is less than the minimum supported version" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(last_unsupported_version)

      expect {
        resource.provider.validate
      }.to raise_error(Puppet::Error, /Chocolatey version must be '0.9.9.0' to manage configuration values with Puppet/)
    end

    it "should write a debug message on password when password is not empty" do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet.expects(:warning).never
      Puppet.expects(:debug).with("The password is not ensurable, so Puppet is unable to change the value using chocolateysource resource. As a workaround, a password change can be in the form of an exec. Reference Chocolateysource[#{name}]")

      resource.provider.validate
    end

    it "should not warn on user/password on newer choco versions" do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should not warn on user/password when choco version is the minimum supported version" do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_version)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should not warn if priority is not set" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should not warn if priority is not set on older unsupported versions" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(last_unsupported_version_priority)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should not warn if priority is 0 on unsupported versions" do
      resource[:priority] = 0

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(last_unsupported_version_priority)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should not warn on priority when choco version is newer than the minimum supported version" do
      resource[:priority] = 10

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should not warn on priority when choco version is the minimum supported version" do
      resource[:priority] = 10

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_version_priority)
      Puppet.expects(:warning).never

      resource.provider.validate
    end

    it "should warn on priority when choco version is less than the minimum supported version" do
      resource[:priority] = 10

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(last_unsupported_version_priority)
      Puppet.expects(:warning).with("Chocolatey is unable to manage priority for sources when version is less than 0.9.9.9. The value you set will be ignored.")

      resource.provider.validate
    end

    it "should pass when ensure is not present and location is empty" do
      no_location_resource = Puppet::Type.type(:chocolateysource).new(:name => 'source', :ensure => :disabled )
      no_location_resource.provider = provider.new(no_location_resource)

      no_location_resource.provider.validate
    end

    it "should fail when ensure => present and location is empty" do
      expect {
        no_location_resource = Puppet::Type.type(:chocolateysource).new(:name => 'source')
        no_location_resource.provider = provider.new(no_location_resource)

        no_location_resource.provider.validate
      }.to raise_error(Exception, /non-empty location/)
      # check for just an exception here
      # In some versions of Puppet, this comes back as ArgumentError
      # In other versions of Puppet, this comes back as Puppet::Error
    end
  end

  context ".flush" do
    resource_name = "yup"
    resource_location = "loc"
    resource_ensure = :present
    resource_priority = 10
    resource_user = "thatguy"
    resource_password = "secrets!"

    before :each do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall).at_most_once
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config).at_most_once
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true).at_most_once
      File.expects(:new).with(choco_config,"r").returns(choco_config_contents).at_most_once

      resource[:name] = resource_name
      resource[:location] = resource_location
      resource[:ensure] = resource_ensure
    end

    it "should ensure a source is present with minimal values set" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--priority', 0,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', 'yup'
                                                     ])

      resource.flush
    end

    it "should ensure a source is present with all values set" do
      resource[:priority] = resource_priority
      resource[:user] = resource_user
      resource[:password] = resource_password

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--user', resource_user,
                                                      '--password', resource_password,
                                                      '--priority', resource_priority,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name
                                                     ])

      resource.flush
    end

    it "should set priority when present" do
      resource[:priority] = resource_priority
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--priority', resource_priority,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name
                                                     ])

      resource.flush
    end

    it "should set user and password when user is present" do
      resource[:user] = resource_user
      resource[:password] = resource_password

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--user', resource_user,
                                                      '--password', resource_password,
                                                      '--priority', 0,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name
                                                     ])

      resource.flush
    end

    it "should set user and password when choco version is newer than the minimum supported version" do
      resource[:user] = resource_user
      resource[:password] = resource_password

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--user', resource_user,
                                                      '--password', resource_password,
                                                      '--priority', 0,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name
                                                     ])

      resource.flush
    end

    it "should set user and password when choco version is the minimum supported version" do
      resource[:user] = resource_user
      resource[:password] = resource_password

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--user', resource_user,
                                                      '--password', resource_password,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name
                                                     ])

      resource.flush
    end

    it "should set priority when choco version is newer than the minimum supported version" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--priority', 0,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name,
                                                     ])

      resource.flush
    end

    it "should set priority when choco version is the minimum supported version" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_version_priority)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--priority', 0,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name,
                                                     ])

      resource.flush
    end

    it "should not set priority when choco version is less than the minimum supported version" do
      resource[:priority] = resource_priority

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(last_unsupported_version_priority)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', resource_name,
                                                     ])

      resource.flush
    end

    it "should disable a source when ensure => disabled" do
      resource[:ensure] = :disabled
      resource[:name] = 'chocolatey'
      resource.provider.disable

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'disable',
                                                      '--name', 'chocolatey'
                                                     ])

      resource.flush
    end

    it "should remove a source when ensure => absent" do
      resource[:ensure] = :absent
      resource.provider.destroy

      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).never
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'remove',
                                                      '--name', resource_name,
                                                     ])

      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'enable',
                                                      '--name', 'yup'
                                                     ]).never

      resource.flush
    end

    it "should provide an error message when choco execution fails" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(newer_choco_version)
      Puppet::Util::Execution.expects(:execute).with([provider.command(:chocolatey),
                                                      'source', 'add',
                                                      '--name', resource_name,
                                                      '--source', resource_location,
                                                      '--priority', 0,
                                                     ]).raises(Puppet::ExecutionFailure, "Nooooo")

      expect { resource.flush }.to raise_error(Puppet::Error, /Unable to set Chocolatey source/)
    end
  end
end
