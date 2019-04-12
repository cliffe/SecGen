require 'spec_helper'

describe 'firewall', :type => :class do
  context 'kernel => Linux' do
    with_debian_facts
    it { should contain_class('firewall::linux').with_ensure('running') }
  end

  context 'kernel => Windows' do
    let(:facts) {{ :kernel => 'Windows' }}
    it { expect { should contain_class('firewall::linux') }.to raise_error(Puppet::Error) }
  end

  context 'kernel => SunOS' do
    let(:facts) {{ :kernel => 'SunOS' }}
    it { expect { should contain_class('firewall::linux') }.to raise_error(Puppet::Error) }
  end

  context 'kernel => Darwin' do
    let(:facts) {{ :kernel => 'Darwin' }}
    it { expect { should contain_class('firewall::linux') }.to raise_error(Puppet::Error) }
  end

  context 'ensure => stopped' do
    with_debian_facts
    let(:params) {{ :ensure => 'stopped' }}
    it { should contain_class('firewall::linux').with_ensure('stopped') }
  end

  context 'ensure => test' do
    let(:facts) {{ :kernel => 'Linux' }}
    let(:params) {{ :ensure => 'test' }}
    it { expect { should contain_class('firewall::linux') }.to raise_error(Puppet::Error) }
  end
end
