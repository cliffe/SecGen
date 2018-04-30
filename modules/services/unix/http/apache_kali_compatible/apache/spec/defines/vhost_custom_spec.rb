require 'spec_helper'

describe 'apache::vhost::custom', :type => :define do
  let :title do
    'rspec.example.com'
  end
  let :default_params do
    {
      :content => 'foobar'
    }
  end
  describe 'os-dependent items' do
    context "on RedHat based systems" do
      let :default_facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :operatingsystem        => 'RedHat',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
    end
    context "on Debian based systems" do
      let :default_facts do
        {
          :osfamily               => 'Debian',
          :operatingsystemrelease => '6',
          :lsbdistcodename        => 'squeeze',
          :operatingsystem        => 'Debian',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_file("apache_rspec.example.com").with(
        :ensure  => 'present',
        :content => 'foobar',
        :path    => '/etc/apache2/sites-available/25-rspec.example.com.conf',
      ) }
      it { is_expected.to contain_file("25-rspec.example.com.conf symlink").with(
        :ensure => 'link',
        :path   => '/etc/apache2/sites-enabled/25-rspec.example.com.conf',
        :target => '/etc/apache2/sites-available/25-rspec.example.com.conf'
      ) }
    end
    context "on FreeBSD systems" do
      let :default_facts do
        {
          :osfamily               => 'FreeBSD',
          :operatingsystemrelease => '9',
          :operatingsystem        => 'FreeBSD',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'FreeBSD',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_file("apache_rspec.example.com").with(
        :ensure  => 'present',
        :content => 'foobar',
        :path    => '/usr/local/etc/apache24/Vhosts/25-rspec.example.com.conf',
      ) }
    end
    context "on Gentoo systems" do
      let :default_facts do
        {
          :osfamily               => 'Gentoo',
          :operatingsystem        => 'Gentoo',
          :operatingsystemrelease => '3.16.1-gentoo',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_file("apache_rspec.example.com").with(
        :ensure  => 'present',
        :content => 'foobar',
        :path    => '/etc/apache2/vhosts.d/25-rspec.example.com.conf',
      ) }
    end
  end
end
