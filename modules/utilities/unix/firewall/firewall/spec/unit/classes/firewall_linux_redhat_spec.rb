require 'spec_helper'

RSpec.shared_examples "ensures iptables service" do
  context 'default' do
    it { should contain_service('iptables').with(
      :ensure => 'running',
      :enable => 'true'
    )}
  end

  context 'ensure => stopped' do
    let(:params) {{ :ensure => 'stopped' }}
    it { should contain_service('iptables').with(
      :ensure => 'stopped'
    )}
  end

  context 'enable => false' do
    let(:params) {{ :enable => 'false' }}
    it { should contain_service('iptables').with(
      :enable => 'false'
    )}
  end
end

describe 'firewall::linux::redhat', :type => :class do
  %w{RedHat CentOS Fedora}.each do |os|
    oldreleases = (os == 'Fedora' ? ['14'] : ['6.5'])
    newreleases = (os == 'Fedora' ? ['15','Rawhide'] : ['7.0.1406'])

    oldreleases.each do |osrel|
      context "os #{os} and osrel #{osrel}" do
        let(:facts) {{
          :operatingsystem        => os,
          :operatingsystemrelease => osrel,
          :osfamily               => 'RedHat',
          :selinux                => false,
        }}

        it { should_not contain_service('firewalld') }
        it { should_not contain_package('iptables-services') }

        it_behaves_like "ensures iptables service"
      end
    end

    newreleases.each do |osrel|
      context "os #{os} and osrel #{osrel}" do
        let(:facts) {{
          :operatingsystem        => os,
          :operatingsystemrelease => osrel,
          :osfamily               => 'RedHat',
          :selinux                => false,
        }}

        it { should contain_service('firewalld').with(
          :ensure => 'stopped',
          :enable => false,
          :before => 'Package[iptables-services]'
        )}

        it { should contain_package('iptables-services').with(
          :ensure => 'present',
          :before => 'Service[iptables]'
        )}

        it_behaves_like "ensures iptables service"
      end
    end
  end
end
