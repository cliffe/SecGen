require 'spec_helper'

describe 'nginx::package' do

  shared_examples 'redhat' do |operatingsystem|
    let(:facts) {{ :operatingsystem => operatingsystem, :osfamily => 'RedHat', :operatingsystemmajrelease => '6' }}
    context "using defaults" do
      it { is_expected.to contain_package('nginx') }
      it { is_expected.to contain_yumrepo('nginx-release').with(
        'baseurl'  => "http://nginx.org/packages/#{operatingsystem == 'CentOS' ? 'centos' : 'rhel'}/6/$basearch/",
        'descr'    => 'nginx repo',
        'enabled'  => '1',
        'gpgcheck' => '1',
        'priority' => '1',
        'gpgkey'   => 'http://nginx.org/keys/nginx_signing.key'
      )}
      it { is_expected.to contain_anchor('nginx::package::begin').that_comes_before('Class[nginx::package::redhat]') }
      it { is_expected.to contain_anchor('nginx::package::end').that_requires('Class[nginx::package::redhat]') }
    end

    context "package_source => nginx-mainline" do
      let(:params) {{ :package_source => 'nginx-mainline' }}
      it { is_expected.to contain_yumrepo('nginx-release').with(
        'baseurl'  => "http://nginx.org/packages/mainline/#{operatingsystem == 'CentOS' ? 'centos' : 'rhel'}/6/$basearch/",
      )}
    end

    context "manage_repo => false" do
      let(:facts) {{ :operatingsystem => operatingsystem, :osfamily => 'RedHat', :operatingsystemmajrelease => '7' }}
      let(:params) {{ :manage_repo => false }}
      it { is_expected.to contain_package('nginx') }
      it { is_expected.not_to contain_yumrepo('nginx-release') }
    end

    context "operatingsystemmajrelease = 5" do
      let(:facts) {{ :operatingsystem => operatingsystem, :osfamily => 'RedHat', :operatingsystemmajrelease => '5' }}
      it { is_expected.to contain_package('nginx') }
      it { is_expected.to contain_yumrepo('nginx-release').with(
        'baseurl'  => "http://nginx.org/packages/#{operatingsystem == 'CentOS' ? 'centos' : 'rhel'}/5/$basearch/"
      )}
    end

    describe 'installs the requested package version' do
      let(:facts) {{ :operatingsystem => 'redhat', :osfamily => 'redhat', :operatingsystemmajrelease => '7'}}
      let(:params) {{ :package_ensure => '3.0.0' }}

      it 'installs 3.0.0 exactly' do
        is_expected.to contain_package('nginx').with({
          'ensure' => '3.0.0'
        })
      end
    end
  end

  shared_examples 'debian' do |operatingsystem, lsbdistcodename, lsbdistid, operatingsystemmajrelease|
    let(:facts) {{
      :operatingsystem => operatingsystem,
      :operatingsystemmajrelease => operatingsystemmajrelease,
      :osfamily        => 'Debian',
      :lsbdistcodename => lsbdistcodename,
      :lsbdistid       => lsbdistid
    }}

    context "using defaults" do
      it { is_expected.to contain_package('nginx') }
      it { is_expected.not_to contain_package('passenger') }
      it { is_expected.to contain_apt__source('nginx').with(
        'location'   => "http://nginx.org/packages/#{operatingsystem.downcase}",
        'repos'      => 'nginx',
        'key'        => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62',
      )}
      it { is_expected.to contain_anchor('nginx::package::begin').that_comes_before('Class[nginx::package::debian]') }
      it { is_expected.to contain_anchor('nginx::package::end').that_requires('Class[nginx::package::debian]') }
    end

    context "package_source => nginx-mainline" do
      let(:params) {{ :package_source => 'nginx-mainline' }}
      it { is_expected.to contain_apt__source('nginx').with(
        'location'   => "http://nginx.org/packages/mainline/#{operatingsystem.downcase}",
      )}
    end

    context "package_source => 'passenger'" do
      let(:params) {{ :package_source => 'passenger' }}
      it { is_expected.to contain_package('nginx') }
      it { is_expected.to contain_package('passenger') }
      it { is_expected.to contain_apt__source('nginx').with(
        'location'   => 'https://oss-binaries.phusionpassenger.com/apt/passenger',
        'repos'      => "main",
        'key'        => '16378A33A6EF16762922526E561F9B9CAC40B2F7',
      )}
    end

    context "manage_repo => false" do
      let(:params) {{ :manage_repo => false }}
      it { is_expected.to contain_package('nginx') }
      it { is_expected.not_to contain_apt__source('nginx') }
      it { is_expected.not_to contain_package('passenger') }
    end
  end

  context 'redhat' do
    it_behaves_like 'redhat', 'CentOS'
    it_behaves_like 'redhat', 'RedHat'
  end

  context 'debian' do
    it_behaves_like 'debian', 'Debian', 'wheezy', 'Debian', '6'
    it_behaves_like 'debian', 'Ubuntu', 'precise', 'Ubuntu', '12.04'
  end

  context 'other' do
    let(:facts) {{ :operatingsystem => 'xxx', :osfamily => 'linux' }}
    it { is_expected.to contain_package('nginx') }
  end
end
