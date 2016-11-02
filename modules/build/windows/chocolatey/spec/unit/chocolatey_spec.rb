# vim: set ts=2 sw=2 ai et ruler:
require 'spec_helper'
require 'stringio'
require 'puppet/provider/package/chocolatey'

provider = Puppet::Type.type(:package).provider(:chocolatey)

describe provider do
  let (:resource) { Puppet::Type.type(:package).new(:provider => :chocolatey, :name => "chocolatey") }

  before :each do
    @provider = provider.new(resource)
    resource.provider = @provider
    #provider.resource = resource

    # Stub all file and config tests
    provider.stubs(:healthcheck)
  end

  it "should be an instance of Puppet::Type::Package::ProviderChocolatey" do
    @provider.must be_an_instance_of Puppet::Type::Package::ProviderChocolatey
  end

  it "should find chocolatey install location based on ChocolateyInstall environment variable", :if => Puppet.features.microsoft_windows? do
    @provider.class.expects(:file_exists?).with('C:\ProgramData\chocolatey\bin\choco.exe').returns(false)
    @provider.class.expects(:file_exists?).with('c:\blah\bin\choco.exe').returns(true)
    # this is a placeholder, it is already set in spec_helper
    ENV['ChocolateyInstall'] = 'c:\blah'
    @provider.class.chocolatey_command.should == 'c:\blah\bin\choco.exe'
  end

  it "should find chocolatey install location based on default location", :if => Puppet.features.microsoft_windows? do
    @provider.class.expects(:file_exists?).with('C:\ProgramData\chocolatey\bin\choco.exe').returns(false)
    @provider.class.expects(:file_exists?).with('c:\blah\bin\choco.exe').returns(false)
    @provider.class.expects(:file_exists?).with('C:\Chocolatey\bin\choco.exe').returns(false)
    @provider.class.expects(:file_exists?).with("#{ENV['ALLUSERSPROFILE']}\\chocolatey\\bin\\choco.exe").returns(true)
    @provider.class.chocolatey_command.should == "#{ENV['ALLUSERSPROFILE']}\\chocolatey\\bin\\choco.exe"
    @provider.class.chocolatey_command
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

  context "when working with new compiled choco" do
    it "should set choco_exe? true" do
      Puppet::Util::Execution.stubs(:execpipe).yields StringIO.new("0.9.9.4\n")

      @provider.class.choco_exe?.must be_truthy
    end
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
        @provider.class.compiled_choco = true
      end

      it "should use install command without versioned package" do
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil)
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
        @provider.expects(:chocolatey).with('install','chocolatey','-y', nil, '-source', 'c:\packages')
        @provider.install
      end
    end

    context "with posh choco client" do
      before :each do
         @provider.class.compiled_choco = false
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
        @provider.expects(:chocolatey).with('install','chocolatey', nil, '-source', 'c:\packages')
        @provider.install
      end
    end
  end

  context "when holding" do
    context "with compiled choco client" do
      before :each do
        @provider.class.compiled_choco = true
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
        @provider.class.compiled_choco = false
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
         @provider.class.compiled_choco = true
      end

      it "should call the remove operation" do
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil)
        @provider.uninstall
      end

      it "should use ignore source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey','-fy', nil)
        @provider.uninstall
      end
    end

    context "with posh choco client" do
      before :each do
         @provider.class.compiled_choco = false
      end

      it "should call the remove operation" do
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey', nil)
        @provider.uninstall
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', nil, '-source', 'c:\packages')
        @provider.uninstall
      end
    end
  end

  context "when updating" do
    context "with compiled choco client" do
      before :each do
         @provider.class.compiled_choco = true
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
        @provider.expects(:chocolatey).with('upgrade','chocolatey', '-y', nil, '-source', 'c:\packages')
        @provider.update
      end
    end

    context "with posh choco client" do
      before :each do
         @provider.class.compiled_choco = false
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
        @provider.expects(:chocolatey).with('update','chocolatey', nil, '-source', 'c:\packages')
        @provider.update
      end
    end
  end

  context "when getting latest" do
    let (:choco_command) {
      if Puppet.features.microsoft_windows?
        @provider.class.chocolatey_command
      else
        nil
      end
    }

    context "with compiled choco client" do
      before :each do
        @provider.class.compiled_choco = true
      end

      it "should use choco.exe arguments" do
        @provider.send(:latestcmd).should == [choco_command, 'upgrade', '--noop', 'chocolatey','-r']
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.send(:latestcmd).should == [choco_command, 'upgrade', '--noop', 'chocolatey','-r', '-source', 'c:\packages']
        #@provider.expects(:chocolatey).with('version', 'chocolatey', '-source', 'c:\packages')
        #@provider.latest
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.compiled_choco = false
      end

      it "should use posh arguments" do
        @provider.send(:latestcmd).should == [choco_command, 'version', 'chocolatey', '| findstr /R "latest" | findstr /V "latestCompare"']
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.send(:latestcmd).should == [choco_command, 'version', 'chocolatey', '-source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"']
        #@provider.expects(:chocolatey).with('version', 'chocolatey', '-source', 'c:\packages')
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

    it "should return nil on error" do
      provider.expects(:execpipe).raises(Puppet::ExecutionFailure.new("ERROR!"))
      provider.instances.should be_nil
    end
  end
end
