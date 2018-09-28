require 'spec_helper'
require 'stringio'
require 'puppet/type/package'
require 'puppet/provider/package/chocolatey'

provider = Puppet::Type.type(:package).provider(:chocolatey)

describe provider do
  let (:resource) { Puppet::Type.type(:package).new(:provider => :chocolatey, :name => "chocolatey") }
  let (:first_compiled_choco_version) {'0.9.9.0'}
  let (:newer_choco_version) {'0.9.10.0'}
  let (:last_posh_choco_version) {'0.9.8.33'}
  let (:minimum_supported_choco_uninstall_source) {'0.9.10.0'}
  let (:minimum_supported_choco_exit_codes) {'0.9.10.0'}
  let (:choco_zero_ten_zero) {'0.10.0'}

  before :each do
    @provider = provider.new(resource)
    resource.provider = @provider

    # Stub all file and config tests
    provider.stubs(:healthcheck)
    Puppet::Util::Execution.stubs(:execute)
  end

  it "should be an instance of Puppet::Type::Package::ProviderChocolatey" do
    @provider.must be_an_instance_of Puppet::Type::Package::ProviderChocolatey
  end

  it "should have an install method" do
    @provider.should respond_to(:install)
  end

  it "should have a latest method" do
    @provider.should respond_to(:uninstall)
  end

  it "should have an update method" do
    @provider.should respond_to(:update)
  end

  it "should have a latest method" do
    @provider.should respond_to(:latest)
  end

  context "parameter :source" do
    it "should default to nil" do
      resource[:source].should be_nil
    end

    it "should accept c:\\packages" do
      resource[:source] = 'c:\packages'
    end

    it "should accept http://somelocation/packages" do
      resource[:source] = 'http://somelocation/packages'
    end

    it "should accept \\\\unc\\share\\packages" do
      resource[:source] = '\\unc\share\packages'
    end
  end

  context "when installing" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should use install command without versioned package" do
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil)

        @provider.install
      end

      it "should call with ignore package exit codes when = 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_exit_codes).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.install
      end

      it "should call with ignore package exit codes when > 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.install
      end

      it "should use upgrade command with versioned package" do
        resource[:ensure] = '1.2.3'
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey', '-version', '1.2.3', '-y', nil)

        @provider.install
      end

      it "should call install instead of upgrade if package name ends with .config" do
        resource[:name] = "packages.config"
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'packages.config','-y', nil)

        @provider.install
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('install','chocolatey','-y', '-source', 'c:\packages', nil)

        @provider.install
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should use install command without versioned package" do
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey', nil)

        @provider.install
      end

      it "should use update command with versioned package" do
        resource[:ensure] = '1.2.3'
        @provider.expects(:chocolatey).with('update', 'chocolatey', '-version', '1.2.3', nil)

        @provider.install
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('install','chocolatey', '-source', 'c:\packages', nil)

        @provider.install
      end
    end
  end

  context "when holding" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should use install command with held package" do
        resource[:ensure] = :held
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil)
        @provider.expects(:chocolatey).with('pin', 'add', '-n', 'chocolatey')

        @provider.hold
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
      end

      it "should throw an argument error with held package" do
        resource[:ensure] = :held

        expect { @provider.hold }.to raise_error(ArgumentError, "Only choco v0.9.9+ can use ensure => held")
      end
    end
  end

  context "when uninstalling" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should call the remove operation" do
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil)

        @provider.uninstall
      end

      it "should call with ignore package exit codes when = 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_exit_codes).at_least_once
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end

      it "should call with ignore package exit codes when > 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end

      it "should use ignore source if it is specified and the version is less than 0.9.10" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey','-fy', nil)

        @provider.uninstall
      end

      it "should use source if it is specified and the version is at least 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_uninstall_source).at_least_once
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', '-fy', '-source', 'c:\packages', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end

      it "should use source if it is specified and the version is greater than 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', '-fy', '-source', 'c:\packages', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should call the remove operation" do
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey', nil)

        @provider.uninstall
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', '-source', 'c:\packages', nil)

        @provider.uninstall
      end
    end
  end

  context "when updating" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should use `chocolatey upgrade` when ensure latest and package present" do
        provider.stubs(:instances).returns [provider.new({
          :ensure   => "1.2.3",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey', '-y', nil)

        @provider.update
      end

      it "should call with ignore package exit codes when = 0.9.10" do
        provider.stubs(:instances).returns [provider.new({
             :ensure   => "1.2.3",
             :name     => "chocolatey",
             :provider => :chocolatey,
         })]
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_exit_codes).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.update
      end

      it "should call with ignore package exit codes when > 0.9.10" do
        provider.stubs(:instances).returns [provider.new({
            :ensure   => "1.2.3",
            :name     => "chocolatey",
            :provider => :chocolatey,
        })]
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.update
      end


      it "should use `chocolatey install` when ensure latest and package absent" do
        provider.stubs(:instances).returns []
        @provider.expects(:chocolatey).with('install', 'chocolatey', '-y', nil)

        @provider.update
      end

      it "should use source if it is specified" do
        provider.expects(:instances).returns [provider.new({
          :ensure   => "latest",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('upgrade','chocolatey', '-y', '-source', 'c:\packages', nil)

        @provider.update
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should use `chocolatey update` when ensure latest and package present" do
        provider.stubs(:instances).returns [provider.new({
          :ensure   => "1.2.3",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        @provider.expects(:chocolatey).with('update', 'chocolatey', nil)

        @provider.update
      end

      it "should use `chocolatey install` when ensure latest and package absent" do
        provider.stubs(:instances).returns []
        @provider.expects(:chocolatey).with('install', 'chocolatey', nil)

        @provider.update
      end

      it "should use source if it is specified" do
        provider.expects(:instances).returns [provider.new({
          :ensure   => "latest",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('update','chocolatey', '-source', 'c:\packages', nil)

        @provider.update
      end
    end
  end

  context "when getting latest" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
      end

      it "should use choco.exe arguments" do
        # we don't care where choco is, we are concerned with the arguments that are passed to choco.
        #
        @provider.send(:latestcmd).drop(1).should == ['upgrade', '--noop', 'chocolatey','-r']
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.send(:latestcmd).drop(1).should == ['upgrade', '--noop', 'chocolatey','-r', '-source', 'c:\packages']
        #@provider.expects(:chocolatey).with('upgrade', '--noop', 'chocolatey','-r', '-source', 'c:\packages')

        #@provider.latest
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should use posh arguments" do
        @provider.send(:latestcmd).drop(1).should == ['version', 'chocolatey', '| findstr /R "latest" | findstr /V "latestCompare"']
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.send(:latestcmd).drop(1).should == ['version', 'chocolatey', '-source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"']
        #@provider.expects(:chocolatey).with('version', 'chocolatey', '-source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"')

        #@provider.latest
      end
    end
  end

  context "query" do
    it "should return a hash when chocolatey and the package are present" do
      provider.expects(:instances).returns [provider.new({
        :ensure   => "1.2.5",
        :name     => "chocolatey",
        :provider => :chocolatey,
      })]

      @provider.query.should == {
        :ensure   => "1.2.5",
        :name     => "chocolatey",
        :provider => :chocolatey,
      }
    end

    it "should return nil when the package is missing" do
      provider.expects(:instances).returns []

      @provider.query.should == nil
    end
  end

  context "when fetching a package list" do
    it "should invoke provider listcmd" do
      provider.expects(:listcmd)

      provider.instances
    end

    it "should query chocolatey" do
      provider.expects(:execpipe).with() do |args|
        args[1] =~ /list/
        args[2] =~ /-lo/
      end

      provider.instances
    end

    context "self.instances" do
      it "should return nil on error" do
        provider.expects(:execpipe).raises(Puppet::ExecutionFailure.new("ERROR!"))

        provider.instances.should be_nil
      end

      context "with compiled choco client" do
        before :each do
          @provider.class.stubs(:is_compiled_choco?).returns(true)
          PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        end

        it "should return installed packages with their versions" do
          provider.expects(:execpipe).yields(StringIO.new(%Q(package1|1.23\n\package2|2.00\n)))

          packages = (provider.instances)

          packages.length.should == 2

          packages[0].properties.should == {
              :provider => :chocolatey,
              :ensure => "1.23",
              :name => 'package1'
          }

          packages[1].properties.should == {
              :provider => :chocolatey,
              :ensure => "2.00",
              :name => 'package2'
          }
        end

        it "should return nil on error" do
          provider.expects(:execpipe).yields(StringIO.new(%Q(Unable to search for packages when there are no soures enabled for packages and none were passed as arguments.\n)))

          expect {
            provider.instances
          }.to raise_error(Puppet::Error, /At least one source must be enabled./)
        end
      end

      context "with posh choco client" do
        before :each do
          @provider.class.stubs(:is_compiled_choco?).returns(false)
          PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
        end

        it "should return installed packages with their versions" do
          provider.expects(:execpipe).yields(StringIO.new(%Q(package1 1.23\n\package2 2.00\n)))

          packages = (provider.instances)

          packages.length.should == 2

          packages[0].properties.should == {
              :provider => :chocolatey,
              :ensure => "1.23",
              :name => 'package1'
          }

          packages[1].properties.should == {
              :provider => :chocolatey,
              :ensure => "2.00",
              :name => 'package2'
          }
        end
      end
    end
  end
end
