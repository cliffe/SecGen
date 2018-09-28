#!/usr/bin/env ruby -S rspec
require 'spec_helper'
require 'puppet/type/registry_value'

describe Puppet::Type.type(:registry_value) do
  let (:catalog) do Puppet::Resource::Catalog.new end

  [:ensure, :type, :data].each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  describe "path parameter" do
    it "should have a path parameter" do
      Puppet::Type.type(:registry_key).attrtype(:path).should == :param
    end

    %w[hklm\propname hklm\software\propname].each do |path|
      it "should accept #{path}" do
        described_class.new(:path => path, :catalog => catalog)
      end
    end

    %w[hklm\\ hklm\software\\ hklm\software\vendor\\].each do |path|
      it "should accept the unnamed (default) value: #{path}" do
        described_class.new(:path => path, :catalog => catalog)
      end
    end

    it "should strip trailling slashes from unnamed values" do
      described_class.new(:path => 'hklm\\software\\\\', :catalog => catalog)
    end

    %w[HKEY_DYN_DATA\\ HKEY_PERFORMANCE_DATA\name].each do |path|
      it "should reject #{path} as unsupported" do
        expect { described_class.new(:path => path, :catalog => catalog) }.to raise_error(Puppet::Error, /Unsupported/)
      end
    end

    %w[hklm hkcr unknown\\name unknown\\subkey\\name].each do |path|
      it "should reject #{path} as invalid" do
        pending 'wrong message'
        expect { described_class.new(:path => path, :catalog => catalog) }.should raise_error(Puppet::Error, /Invalid registry key/)
      end
    end

    %w[HKLM\\name HKEY_LOCAL_MACHINE\\name hklm\\name].each do |root|
      it "should canonicalize root key #{root}" do
        value = described_class.new(:path => root, :catalog => catalog)
        value[:path].should == 'hklm\name'
      end
    end

    it 'should validate the length of the value name'
    it 'should validate the length of the value data'
    it 'should be case-preserving'
    it 'should be case-insensitive'
    it 'should autorequire ancestor keys'
    it 'should support 32-bit values' do
      value = described_class.new(:path => '32:hklm\software\foo', :catalog => catalog)
    end
  end

  describe "type property" do
    let (:value) { described_class.new(:path => 'hklm\software\foo', :catalog => catalog) }

    [:string, :array, :dword, :qword, :binary, :expand].each do |type|
      it "should support a #{type.to_s} type" do
        value[:type] = type
        value[:type].should == type
      end
    end

    it "should reject other types" do
      expect { value[:type] = 'REG_SZ' }.to raise_error(Puppet::Error)
    end
  end

  describe "data property" do
    let (:value) { described_class.new(:path => 'hklm\software\foo', :catalog => catalog) }

    context "string data" do
      ['', 'foobar'].each do |data|
        it "should accept '#{data}'" do
          value[:type] = :string
          value[:data] = data
        end
      end

      pending "it should accept nil"
    end

    context "integer data" do
      [:dword, :qword].each do |type|
        context "for #{type}" do
          [0, 0xFFFFFFFF, -1, 42].each do |data|
            it "should accept #{data}" do
              value[:type] = type
              value[:data] = data
            end
          end

          %w['foobar' :true].each do |data|
            it "should reject #{data}" do
              value[:type] = type
              expect { value[:data] = data }.to raise_error(Puppet::Error)
            end
          end
        end
      end

      context "for 64-bit integers" do
        let :data do 0xFFFFFFFFFFFFFFFF end

        it "should accept qwords" do
          value[:type] = :qword
          value[:data] = data
        end

        it "should reject dwords" do
          value[:type] = :dword
          expect { value[:data] = data }.to raise_error(Puppet::Error)
        end
      end
    end

    context "binary data" do
      ['', 'CA FE BE EF', 'DEADBEEF'].each do |data|
        it "should accept '#{data}'" do
          value[:type] = :binary
          value[:data] = data
        end
      end
      [9,'1','A'].each do |data|
        it "should accept '#{data}' and have a leading zero" do
          value[:type] = :binary
          value[:data] = data
        end
      end

      ["\040\040", 'foobar', :true].each do |data|
        it "should reject '#{data}'" do
          value[:type] = :binary
          expect { value[:data] = data }.to raise_error(Puppet::Error)
        end
      end
    end

    context "array data" do
      it "should support array data" do
        value[:type] = :array
        value[:data] = ['foo', 'bar', 'baz']
      end
    end
  end
end
