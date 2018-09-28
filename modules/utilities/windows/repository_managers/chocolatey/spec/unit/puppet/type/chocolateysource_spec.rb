require 'spec_helper'
require 'puppet/type/chocolateysource'

describe Puppet::Type.type(:chocolateysource) do
  let(:resource) { Puppet::Type.type(:chocolateysource).new(:name => 'source', :location => 'c:\packages') }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let (:minimum_supported_version) {'0.9.9.0'}

  before :each do
    PuppetX::Chocolatey::ChocolateyCommon.stubs(:choco_version).returns(minimum_supported_version)

    resource.provider = provider
  end

  it "should be an instance of Puppet::Type::Chocolateysource" do
    resource.must be_an_instance_of Puppet::Type::Chocolateysource
  end

  it "parameter :name should be the name var" do
    resource.parameters[:name].isnamevar?.should be_truthy
  end

  #string values
  ['name','location','user','password'].each do |param|
    context "parameter :#{param}" do
      let (:param_symbol) { param.to_sym }

      it "should accept any string value" do
        resource[param_symbol] = 'value'
        resource[param_symbol] = "c:/thisstring-location/value/somefile.txt"
        resource[param_symbol] = "c:\\thisstring-location\\value\\somefile.txt"
      end
    end
  end

  #numeric values
  ['priority'].each do |param|
    context "parameter :#{param}" do
      let (:param_symbol) { param.to_sym }

      it "should accept any numeric value" do
        resource[param_symbol] = 0
        resource[param_symbol] = 10
      end

      it "should accept any string that represents a numeric value" do
        resource[param_symbol] = '1'
        resource[param_symbol] = '0'
      end

      it "should not accept other string values" do
        expect {
          resource[param_symbol] = 'value'
        }.to raise_error(Puppet::Error, /An integer is necessary for #{param}/)
      end

      it "should not accept symbol values" do
        expect {
          resource[param_symbol] = :whenever
        }.to raise_error(Puppet::Error, /An integer is necessary for #{param}/)
      end
    end
  end

  context "param :ensure" do
    it "should accept 'present'" do
      resource[:ensure] = 'present'
    end

    it "should accept present" do
      resource[:ensure] = :present
    end

    it "should accept :disabled" do
      resource[:ensure] = :disabled
    end

    it "should accept absent" do
      resource[:ensure] = :absent
    end

    it "should reject any other value" do
      expect {
        resource[:ensure] = :whenever
      }.to raise_error(Puppet::Error, /Invalid value :whenever. Valid values are/)
    end
  end

  it "should autorequire Exec[install_chocolatey_official] when in the catalog" do
    exec = Puppet::Type.type(:exec).new(:name => "install_chocolatey_official", :path => "nope")
    catalog.add_resource resource
    catalog.add_resource exec

    reqs = resource.autorequire
    reqs.count.must == 1
    reqs[0].source.must == exec
    reqs[0].target.must == resource
  end

  context ".validate" do
    it "should pass when both user/password are empty" do
      resource.validate
    end

    it "should pass when both user/password have a value" do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      resource.validate
    end

    it "should fail when user has a value but password does not" do
      resource[:user] = 'tim'

      expect {
        resource.validate
      }.to raise_error(ArgumentError, /you must specify both values/)
    end

    it "should fail when password has a value but user does not" do
      resource[:password] = 'tim'

      expect {
        resource.validate
      }.to raise_error(ArgumentError, /you must specify both values/)
    end
  end
end
