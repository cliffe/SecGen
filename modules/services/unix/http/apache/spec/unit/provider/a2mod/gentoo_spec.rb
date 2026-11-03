require 'spec_helper'

provider_class = Puppet::Type.type(:a2mod).provider(:gentoo)

describe provider_class do
  before :each do
    provider_class.clear
  end

  [:conf_file, :instances, :modules, :initvars, :conf_file, :clear].each do |method|
    it "should respond to the class method #{method}" do
      expect(provider_class).to respond_to(method)
    end
  end

  describe "when fetching modules" do
    before do
      @filetype = double()
    end

    it "should return a sorted array of the defined parameters" do
      expect(@filetype).to receive(:read) { %Q{APACHE2_OPTS="-D FOO -D BAR -D BAZ"\n} }
      expect(provider_class).to receive(:filetype) { @filetype }

      expect(provider_class.modules).to eq(%w{bar baz foo})
    end

    it "should cache the module list" do
      expect(@filetype).to receive(:read).once { %Q{APACHE2_OPTS="-D FOO -D BAR -D BAZ"\n} }
      expect(provider_class).to receive(:filetype).once { @filetype }

      2.times { expect(provider_class.modules).to eq(%w{bar baz foo}) }
    end

    it "should normalize parameters" do
      @filetype.expects(:read).returns(%Q{APACHE2_OPTS="-D FOO -D BAR -D BAR"\n})
      provider_class.expects(:filetype).returns(@filetype)

      expect(provider_class.modules).to eq(%w{bar foo})
    end
  end

  describe "when prefetching" do
    it "should match providers to resources" do
      provider = double("ssl_provider", :name => "ssl")
      resource = double("ssl_resource")
      resource.expects(:provider=).with(provider)

      expect(provider_class).to receive(:instances) { [provider] }
      provider_class.prefetch("ssl" => resource)
    end
  end

  describe "when flushing" do
    before :each do
      @filetype = double()
      allow(@filetype).to receive(:backup)
      allow(provider_class).to receive(:filetype).at_least(:once) { @filetype }

      @info = double()
      allow(@info).to receive(:[]).with(:name) { "info" }
      allow(@info).to receive(:provider=)

      @mpm = double()
      allow(@mpm).to receive(:[]).with(:name) { "mpm" }
      allow(@mpm).to receive(:provider=)

      @ssl = double()
      allow(@ssl).to receive(:[]).with(:name) { "ssl" }
      allow(@ssl).to receive(:provider=)
    end

    it "should add modules whose ensure is present" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS=""} }
      expect(@filetype).to receive(:write).with(%Q{APACHE2_OPTS="-D INFO"})

      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)

      provider_class.flush
    end

    it "should remove modules whose ensure is present" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS="-D INFO"} }
      expect(@filetype).to receive(:write).with(%Q{APACHE2_OPTS=""})

      allow(@info).to receive(:should).with(:ensure) { :absent }
      allow(@info).to receive(:provider=)
      provider_class.prefetch("info" => @info)

      provider_class.flush
    end

    it "should not modify providers without resources" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS="-D INFO -D MPM"} }
      expect(@filetype).to receive(:write).with(%Q{APACHE2_OPTS="-D MPM -D SSL"})

      allow(@info).to receive(:should).with(:ensure) { :absent }
      provider_class.prefetch("info" => @info)

      allow(@ssl).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("ssl" => @ssl)

      provider_class.flush
    end

    it "should write the modules in sorted order" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS=""} }
      expect(@filetype).to receive(:write).with(%Q{APACHE2_OPTS="-D INFO -D MPM -D SSL"})

      allow(@mpm).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("mpm" => @mpm)
      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)
      allow(@ssl).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("ssl" => @ssl)

      provider_class.flush
    end

    it "should write the records back once" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS=""} }
      expect(@filetype).to receive(:write).once.with(%Q{APACHE2_OPTS="-D INFO -D SSL"})

      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)

      allow(@ssl).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("ssl" => @ssl)

      provider_class.flush
    end

    it "should only modify the line containing APACHE2_OPTS" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{# Comment\nAPACHE2_OPTS=""\n# Another comment} }
      expect(@filetype).to receive(:write).once.with(%Q{# Comment\nAPACHE2_OPTS="-D INFO"\n# Another comment})

      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)
      provider_class.flush
    end

    it "should restore any arbitrary arguments" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS="-Y -D MPM -X"} }
      expect(@filetype).to receive(:write).once.with(%Q{APACHE2_OPTS="-Y -X -D INFO -D MPM"})

      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)
      provider_class.flush
    end

    it "should backup the file once if changes were made" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS=""} }
      expect(@filetype).to receive(:write).once.with(%Q{APACHE2_OPTS="-D INFO -D SSL"})

      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)

      allow(@ssl).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("ssl" => @ssl)

      @filetype.unstub(:backup)
      @filetype.expects(:backup)
      provider_class.flush
    end

    it "should not write the file or run backups if no changes were made" do
      expect(@filetype).to receive(:read).at_least(:once) { %Q{APACHE2_OPTS="-X -D INFO -D SSL -Y"} }
      expect(@filetype).to receive(:write).never

      allow(@info).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("info" => @info)

      allow(@ssl).to receive(:should).with(:ensure) { :present }
      provider_class.prefetch("ssl" => @ssl)

      @filetype.unstub(:backup)
      @filetype.expects(:backup).never
      provider_class.flush
    end
  end
end
