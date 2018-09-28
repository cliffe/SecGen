require 'spec_helper'
require 'puppet/type/chocolateyconfig'

describe Puppet::Type.type(:chocolateyconfig) do
  let(:resource) { Puppet::Type.type(:chocolateyconfig).new(:name => "config", :ensure => :absent) }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let (:minimum_supported_version) {'0.9.10.0'}

  before :each do
    PuppetX::Chocolatey::ChocolateyCommon.stubs(:choco_version).returns(minimum_supported_version)

    resource.provider = provider
  end

  it "should be an instance of Puppet::Type::Chocolateyconfig" do
    resource.must be_an_instance_of Puppet::Type::Chocolateyconfig
  end

  it "parameter :name should be the name var" do
    resource.parameters[:name].isnamevar?.should be_truthy
  end

  #string values
  ['name','value'].each do |param|
    context "parameter :#{param}" do
      let (:param_symbol) { param.to_sym }

      it "should not allow nil" do
        expect {
          resource[param_symbol] = nil
        }.to raise_error(Puppet::Error, /Got nil value for #{param}/)
      end

      it "should not allow empty" do
        expect {
          resource[param_symbol] = ''
        }.to raise_error(Puppet::Error, /A non-empty #{param} must/)
      end

      it "should accept any string value" do
        resource[param_symbol] = 'value'
        resource[param_symbol] = "c:/thisstring-location/value/somefile.txt"
        resource[param_symbol] = "c:\\thisstring-location\\value\\somefile.txt"
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
    it "should pass when ensure => absent with no value" do
      resource[:ensure] = :absent

      resource.validate
    end

    it "should pass when ensure => present with a value" do
      resource[:ensure] = :present
      resource[:value] = 'yo'

      resource.validate
    end

    it "should fail when ensure => present with no value" do
      resource[:ensure] = :present

      expect {
        resource.validate
      }.to raise_error(ArgumentError, /Unless ensure => absent, value is required/)
    end
  end

end
