#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'facter/util/puppet_settings'

describe Facter::Util::PuppetSettings do
  describe '#with_puppet' do
    context 'without Puppet loaded' do
      before(:each) do
        Module.expects(:const_get).with('Puppet').raises(NameError)
      end

      it 'is nil' do
        expect(subject.with_puppet { Puppet[:vardir] }).to be_nil
      end
      it 'does not yield to the block' do
        Puppet.expects(:[]).never
        expect(subject.with_puppet { Puppet[:vardir] }).to be_nil
      end
    end
    context 'with Puppet loaded' do
      module Puppet; end
      let(:vardir) { '/var/lib/puppet' }

      before :each do
        Puppet.expects(:[]).with(:vardir).returns vardir
      end

      it 'yields to the block' do
        subject.with_puppet { Puppet[:vardir] }
      end
      it 'returns the nodes vardir' do
        expect(subject.with_puppet { Puppet[:vardir] }).to eq vardir
      end
    end
  end
end
