require 'spec_helper'

describe 'apache::mod::ldap', :type => :class do
  it_behaves_like "a mod class, without including apache"

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

    context 'set multiple ldap params' do
      let(:params) {{
        :ldap_trusted_global_cert_file => 'ca.pem',
        :ldap_trusted_global_cert_type => 'CA_DER',
        :ldap_shared_cache_size        => '500000',
        :ldap_cache_entries            => '1024',
        :ldap_cache_ttl                => '600',
        :ldap_opcache_entries          => '1024',
        :ldap_opcache_ttl              => '600'
      }}
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPTrustedGlobalCert CA_DER ca\.pem$/) }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPSharedCacheSize 500000$/) }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPCacheEntries 1024$/) }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPCacheTTL 600$/) }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPOpCacheEntries 1024$/) }
      it { is_expected.to contain_file('ldap.conf').with_content(/^LDAPOpCacheTTL 600$/) }
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
