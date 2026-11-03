require 'spec_helper'

describe 'apache::mod::ext_filter', :type => :class do
  it_behaves_like "a mod class, without including apache"
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :fqdn                   => 'test.example.com',
        :is_pe                  => false,
      }
    end
    describe 'with no parameters' do
      it { is_expected.to contain_apache__mod('ext_filter') }
      it { is_expected.not_to contain_file('ext_filter.conf') }
    end
    describe 'with parameters' do
      let :params do
        { :ext_filter_define =>  {'filtA' => 'input=A output=B',
                                  'filtB' => 'input=C cmd="C"' },
        }
      end
      it { is_expected.to contain_file('ext_filter.conf').with_content(/^ExtFilterDefine\s+filtA\s+input=A output=B$/) }
      it { is_expected.to contain_file('ext_filter.conf').with_content(/^ExtFilterDefine\s+filtB\s+input=C cmd="C"$/) }
    end

  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :fqdn                   => 'test.example.com',
        :is_pe                  => false,
      }
    end
    describe 'with no parameters' do
      it { is_expected.to contain_apache__mod('ext_filter') }
      it { is_expected.not_to contain_file('ext_filter.conf') }
    end
    describe 'with parameters' do
      let :params do
        { :ext_filter_define =>  {'filtA' => 'input=A output=B',
                                  'filtB' => 'input=C cmd="C"' },
        }
      end
      it { is_expected.to contain_file('ext_filter.conf').with_path('/etc/httpd/conf.d/ext_filter.conf') }
      it { is_expected.to contain_file('ext_filter.conf').with_content(/^ExtFilterDefine\s+filtA\s+input=A output=B$/) }
      it { is_expected.to contain_file('ext_filter.conf').with_content(/^ExtFilterDefine\s+filtB\s+input=C cmd="C"$/) }
    end
  end
end
