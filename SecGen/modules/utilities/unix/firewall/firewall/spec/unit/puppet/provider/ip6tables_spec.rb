#!/usr/bin/env rspec

require 'spec_helper'
if Puppet.version < '3.4.0'
  require 'puppet/provider/confine/exists'
else
  require 'puppet/confine/exists'
end
provider_class = Puppet::Type.type(:firewall).provider(:ip6tables)
describe 'ip6tables' do
  let(:params) { {:name => '000 test foo', :action => 'accept'} }
  let(:provider) { provider_class }
  let(:resource) { Puppet::Type.type(:firewall) }
  let(:ip6tables_version) { '1.4.0' }

  before :each do

  end

  def stub_iptables
    allow(Puppet::Type::Firewall).to receive(:defaultprovider).and_return provider
    # Stub confine facts
    allow(provider).to receive(:command).with(:iptables_save).and_return "/sbin/iptables-save"

    allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
    allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('Debian')
    allow(Facter.fact('ip6tables_version')).to receive(:value).and_return(ip6tables_version)
    allow(Puppet::Util::Execution).to receive(:execute).and_return ""
    allow(Puppet::Util).to receive(:which).with("iptables-save").
                               and_return "/sbin/iptables-save"
  end

  shared_examples 'raise error' do
    it {
      stub_iptables
      expect {
        provider.new(resource.new(params))
      }.to raise_error(Puppet::DevError, error_message)
    }
  end
  shared_examples 'run' do
    it {
      stub_iptables
      provider.new(resource.new(params))
    }
  end
  context 'iptables 1.3' do
    let(:params) { {:name => '000 test foo', :action => 'accept'} }
    let(:error_message) { /The ip6tables provider is not supported on version 1\.3 of iptables/ }
    let(:ip6tables_version) { '1.3.10' }
    it_should_behave_like 'raise error'
  end
  context 'ip6tables nil' do
    let(:params) { {:name => '000 test foo', :action => 'accept'} }
    let(:error_message) { /The ip6tables provider is not supported on version 1\.3 of iptables/ }
    let(:ip6tables_version) { nil }
    it_should_behave_like 'run'
  end


end
