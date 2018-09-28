require 'spec_helper'
require 'puppet/type/chocolateyfeature'

describe Puppet::Type.type(:chocolateyfeature) do
  let(:resource) { Puppet::Type.type(:chocolateyfeature).new(:name => "chocolateyfeature", :ensure => "enabled" ) }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let (:minimum_supported_version) {'0.9.9.0'}

  before :each do
    PuppetX::Chocolatey::ChocolateyCommon.stubs(:choco_version).returns(minimum_supported_version)

    resource.provider = provider
    resource[:ensure] = 'enabled'
  end

  it "should be an instance of Puppet::Type::Chocolateyfeature" do
    resource.must be_an_instance_of Puppet::Type::Chocolateyfeature
  end

  it "parameter :name should be the name var" do
    resource.parameters[:name].isnamevar?.should be_truthy
  end

  context "parameter :name" do
    let (:param_symbol) { :name }

    it "should accept any string value" do
      resource[param_symbol] = 'value'
      resource[param_symbol] = "c:/thisstring-location/value/somefile.txt"
      resource[param_symbol] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

  context "param :ensure" do
    it "should accept 'enabled'" do
      resource[:ensure] = 'enabled'
    end

    it "should accept enabled" do
      resource[:ensure] = :enabled
    end

    it "should accept 'disabled'" do
      resource[:ensure] = 'disabled'
    end

    it "should accept :disabled" do
      resource[:ensure] = :disabled
    end

    it "should reject any other value" do
      expect {
        resource[:ensure] = :whenever
      }.to raise_error(Puppet::Error, /Invalid value :whenever. Valid values are/)
    end
  end
end
