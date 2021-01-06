#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission : Rubocop error??
require 'spec_helper'
require 'puppet/type'
require 'puppet/type/service'

describe 'service_provider', :type => :fact do
  before(:each) { Facter.clear }
  after(:each) { Facter.clear }

  context 'when macosx' do
    it 'returns launchd' do
      provider = Puppet::Type.type(:service).provider(:launchd)
      Puppet::Type.type(:service).stubs(:defaultprovider).returns provider

      expect(Facter.fact(:service_provider).value).to eq('launchd')
    end
  end

  context 'when systemd' do
    it 'returns systemd' do
      provider = Puppet::Type.type(:service).provider(:systemd)
      Puppet::Type.type(:service).stubs(:defaultprovider).returns provider

      expect(Facter.fact(:service_provider).value).to eq('systemd')
    end
  end

  context 'when redhat' do
    it 'returns redhat' do
      provider = Puppet::Type.type(:service).provider(:redhat)
      Puppet::Type.type(:service).stubs(:defaultprovider).returns provider

      expect(Facter.fact(:service_provider).value).to eq('redhat')
    end
  end
end
