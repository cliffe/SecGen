require 'spec_helper'

describe 'apache::mod::ldap', :type => :class do
  let :pre_condition do
    'include apache'
  end

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
    it { is_expected.to contain_apache__mod('ldap') }

    context 'default ldap_trusted_global_cert_file' do
      it { is_expected.to contain_file('ldap.conf').without_content(/^LDAPTrustedGlobalCert/) }
    end

    context 'ldap_trusted_global_cert_file param' do
      let(:params) { { :ldap_trusted_global_cert_file => 'ca.pem' } }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPTrustedGlobalCert CA_BASE64 ca\.pem$/) }
    end

    context 'ldap_trusted_global_cert_file and ldap_trusted_global_cert_type params' do
      let(:params) {{
        :ldap_trusted_global_cert_file => 'ca.pem',
        :ldap_trusted_global_cert_type => 'CA_DER'
      }}
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPTrustedGlobalCert CA_DER ca\.pem$/) }
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
    it { is_expected.to contain_apache__mod('ldap') }

    context 'default ldap_trusted_global_cert_file' do
      it { is_expected.to contain_file('ldap.conf').without_content(/^LDAPTrustedGlobalCert/) }
    end

    context 'ldap_trusted_global_cert_file param' do
      let(:params) { { :ldap_trusted_global_cert_file => 'ca.pem' } }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPTrustedGlobalCert CA_BASE64 ca\.pem$/) }
    end

    context 'ldap_trusted_global_cert_file and ldap_trusted_global_cert_type params' do
      let(:params) {{
        :ldap_trusted_global_cert_file => 'ca.pem',
        :ldap_trusted_global_cert_type => 'CA_DER'
      }}
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPTrustedGlobalCert CA_DER ca\.pem$/) }
    end
  end # Redhat
end
