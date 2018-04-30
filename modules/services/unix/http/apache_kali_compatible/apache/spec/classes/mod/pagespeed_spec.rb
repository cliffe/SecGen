require 'spec_helper'

describe 'apache::mod::pagespeed', :type => :class do
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
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('pagespeed') }
    it { is_expected.to contain_package("mod-pagespeed-stable") }

    context "when setting additional_configuration to a Hash" do
      let :params do { :additional_configuration => { 'Key' => 'Value' } } end
      it { is_expected.to contain_file('pagespeed.conf').with_content /Key Value/ }
    end

    context "when setting additional_configuration to an Array" do
      let :params do { :additional_configuration => [ 'Key Value' ] } end
      it { is_expected.to contain_file('pagespeed.conf').with_content /Key Value/ }
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
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('pagespeed') }
    it { is_expected.to contain_package("mod-pagespeed-stable") }
    it { is_expected.to contain_file('pagespeed.conf') }
  end
end
