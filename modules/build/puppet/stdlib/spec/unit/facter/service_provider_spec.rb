#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'puppet/type'
require 'puppet/type/service'

describe 'service_provider', :type => :fact do
  before { Facter.clear }
  after { Facter.clear }

  context "macosx" do
    it "should return launchd" do
      provider = Puppet::Type.type(:service).provider(:launchd)
      Puppet::Type.type(:service).stubs(:defaultprovider).returns provider

      expect(Facter.fact(:service_provider).value).to eq('launchd')
    end
  end

  context "systemd" do
    it "should return systemd" do
      provider = Puppet::Type.type(:service).provider(:systemd)
      Puppet::Type.type(:service).stubs(:defaultprovider).returns provider

      expect(Facter.fact(:service_provider).value).to eq('systemd')
    end
  end

  context "redhat" do
    it "should return redhat" do
      provider = Puppet::Type.type(:service).provider(:redhat)
      Puppet::Type.type(:service).stubs(:defaultprovider).returns provider

      expect(Facter.fact(:service_provider).value).to eq('redhat')
    end
  end

end
