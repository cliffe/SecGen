require 'spec_helper'

describe 'apache::mod::authnz_ldap', :type => :class do
  it_behaves_like "a mod class, without including apache"

  context "default configuration with parameters" do
    context "on a Debian OS" do
      let :facts do
        {
          :lsbdistcodename        => 'squeeze',
          :osfamily               => 'Debian',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :operatingsystem        => 'Debian',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_class("apache::mod::ldap") }
      it { is_expected.to contain_apache__mod('authnz_ldap') }

      context 'default verify_server_cert' do
        it { is_expected.to contain_file('authnz_ldap.conf').with_content(/^LDAPVerifyServerCert On$/) }
      end

      context 'verify_server_cert = false' do
        let(:params) { { :verify_server_cert => false } }
        it { is_expected.to contain_file('authnz_ldap.conf').with_content(/^LDAPVerifyServerCert Off$/) }
      end

      context 'verify_server_cert = wrong' do
        let(:params) { { :verify_server_cert => 'wrong' } }
        it 'should raise an error' do
          expect { is_expected.to raise_error Puppet::Error }
        end
      end
    end #Debian

    context "on a RedHat OS" do
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :operatingsystem        => 'RedHat',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_class("apache::mod::ldap") }
      it { is_expected.to contain_apache__mod('authnz_ldap') }

      context 'default verify_server_cert' do
        it { is_expected.to contain_file('authnz_ldap.conf').with_content(/^LDAPVerifyServerCert On$/) }
      end

      context 'verify_server_cert = false' do
        let(:params) { { :verify_server_cert => false } }
        it { is_expected.to contain_file('authnz_ldap.conf').with_content(/^LDAPVerifyServerCert Off$/) }
      end

      context 'verify_server_cert = wrong' do
        let(:params) { { :verify_server_cert => 'wrong' } }
        it 'should raise an error' do
          expect { is_expected.to raise_error Puppet::Error }
        end
      end
    end # Redhat
  end
end
