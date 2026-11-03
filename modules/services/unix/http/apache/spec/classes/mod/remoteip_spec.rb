require 'spec_helper'

describe 'apache::mod::remoteip', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '8',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'jessie',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end
    let :params do
      { :apache_version => '2.4' }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('remoteip') }
    it { is_expected.to contain_file('remoteip.conf').with({
      'path' => '/etc/apache2/mods-available/remoteip.conf',
    }) }

    describe "with header X-Forwarded-For" do
      let :params do
        { :header => 'X-Forwarded-For' }
      end
      it { is_expected.to contain_file('remoteip.conf').with_content(/^RemoteIPHeader X-Forwarded-For$/) }
    end
    describe "with proxy_ips => [ 10.42.17.8, 10.42.18.99 ]" do
      let :params do
        { :proxy_ips => [ '10.42.17.8', '10.42.18.99' ] }
      end
      it { is_expected.to contain_file('remoteip.conf').with_content(/^RemoteIPInternalProxy 10.42.17.8$/) }
      it { is_expected.to contain_file('remoteip.conf').with_content(/^RemoteIPInternalProxy 10.42.18.99$/) }
    end
    describe "with Apache version < 2.4" do
      let :params do
        { :apache_version => '2.2' }
      end
      it 'should fail' do
        expect { catalogue }.to raise_error(Puppet::Error, /mod_remoteip is only available in Apache 2.4/)
      end
    end
  end
end
