#!/usr/bin/env ruby -S rspec
require 'spec_helper'
require 'puppet/resource'
require 'puppet/resource/catalog'
require 'puppet/type/registry_key'

describe Puppet::Type.type(:registry_key) do
  let (:catalog) do Puppet::Resource::Catalog.new end


  # This is overridden here so we get a consistent association with the key
  # and a catalog using memoized let methods.
  let (:key) do
    Puppet::Type.type(:registry_key).new(:name => 'HKLM\Software', :catalog => catalog)
  end
  let(:provider) { Puppet::Provider.new(key) }

  before :each do
    key.provider = provider
  end

  [:ensure].each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  describe "path parameter" do
    it "should have a path parameter" do
      Puppet::Type.type(:registry_key).attrtype(:path).must == :param
    end

    %w[hklm hklm\software hklm\software\vendor].each do |path|
      it "should accept #{path}" do
        key[:path] = path
      end
    end
    
    %w[hku hku\.DEFAULT hku\.DEFAULT\software hku\.DEFAULT\software\vendor].each do |path|
      it "should accept #{path}" do
        key[:path] = path
      end
    end

    %w[HKEY_DYN_DATA HKEY_PERFORMANCE_DATA].each do |path|
      it "should reject #{path} as unsupported case insensitively" do
        expect { key[:path] = path }.to raise_error(Puppet::Error, /Unsupported/)
      end
    end

    %w[hklm\\ hklm\foo\\ unknown unknown\subkey \:hkey].each do |path|
      it "should reject #{path} as invalid" do
        path = "hklm\\" + 'a' * 256
        expect { key[:path] = path }.to raise_error(Puppet::Error, /Invalid registry key/)
      end
    end

    %w[HKLM HKEY_LOCAL_MACHINE hklm].each do |root|
      it "should canonicalize the root key #{root}" do
        key[:path] = root
        key[:path].must == 'hklm'
      end
    end

    it 'should be case-preserving'
    it 'should be case-insensitive'
    it 'should autorequire ancestor keys'
    it 'should support 32-bit keys' do
      key[:path] = '32:hklm\software'
    end
  end

  describe "#eval_generate" do
    context "not purging" do
      it "should return an empty array" do
        key.eval_generate.must be_empty
      end
    end

    context "purging" do
      let (:catalog) do Puppet::Resource::Catalog.new end

      # This is overridden here so we get a consistent association with the key
      # and a catalog using memoized let methods.
      let (:key) do
        Puppet::Type.type(:registry_key).new(:name => 'HKLM\Software', :catalog => catalog)
      end

      before :each do
        key[:purge_values] = true
        catalog.add_resource(key)
        catalog.add_resource(Puppet::Type.type(:registry_value).new(:path => "#{key[:path]}\\val1", :catalog => catalog))
        catalog.add_resource(Puppet::Type.type(:registry_value).new(:path => "#{key[:path]}\\val2", :catalog => catalog))
      end

      it "should return an empty array if the key doesn't have any values" do
        key.provider.expects(:values).returns([])
        key.eval_generate.must be_empty
      end

      it "should purge existing values that are not being managed" do
        key.provider.expects(:values).returns(['val1', 'val3'])
        res = key.eval_generate.first

        res[:ensure].must == :absent
        res[:path].must == "#{key[:path]}\\val3"
      end

      it "should return an empty array if all existing values are being managed" do
        key.provider.expects(:values).returns(['val1', 'val2'])
        key.eval_generate.must be_empty
      end
    end
  end

  describe "#autorequire" do
    let :the_catalog do
      Puppet::Resource::Catalog.new
    end

    let(:the_resource_name) { 'HKLM\Software\Vendor\PuppetLabs' }

    let :the_resource do
      # JJM Holy cow this is an intertangled mess.  ;)
      resource = Puppet::Type.type(:registry_key).new(:name => the_resource_name, :catalog => the_catalog)
      the_catalog.add_resource resource
      resource
    end

    it 'Should initialize the catalog instance variable' do
      the_resource.catalog.must be the_catalog
    end

    it 'Should allow case insensitive lookup using the downcase path' do
      the_resource.must be the_catalog.resource(:registry_key, the_resource_name.downcase)
    end

    it 'Should preserve the case of the user specified path' do
      the_resource.must be the_catalog.resource(:registry_key, the_resource_name)
    end

    it 'Should return the same resource regardless of the alias used' do
      the_resource.must be the_catalog.resource(:registry_key, the_resource_name)
      the_resource.must be the_catalog.resource(:registry_key, the_resource_name.downcase)
    end
  end
end
