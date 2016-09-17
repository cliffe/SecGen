require 'spec_helper'

describe 'firewall::linux', :type => :class do
  context 'RedHat like' do
    %w{RedHat CentOS Fedora}.each do |os|
      context "operatingsystem => #{os}" do
        releases = (os == 'Fedora' ? ['14','15','Rawhide'] : ['6','7'])
        releases.each do |osrel|
          context "operatingsystemrelease => #{osrel}" do
            let(:facts) {{
              :kernel                 => 'Linux',
              :operatingsystem        => os,
              :operatingsystemrelease => osrel,
              :osfamily               => 'RedHat',
              :selinux                => false,
            }}
            it { should contain_class('firewall::linux::redhat').with_require('Package[iptables]') }
            it { should contain_package('iptables').with_ensure('present') }
          end
        end
      end
    end
  end

  context 'Debian like' do
    %w{Debian Ubuntu}.each do |os|
      context "operatingsystem => #{os}" do
        releases = (os == 'Debian' ? ['6','7','8'] : ['10.04','12.04','14.04'])
        releases.each do |osrel|
          let(:facts) {{
            :kernel                 => 'Linux',
            :operatingsystem        => os,
            :operatingsystemrelease => osrel,
            :osfamily               => 'Debian',
            :selinux                => false,
          }}

          it { should contain_class('firewall::linux::debian').with_require('Package[iptables]') }
          it { should contain_package('iptables').with_ensure('present') }
        end
      end
    end
  end
end
