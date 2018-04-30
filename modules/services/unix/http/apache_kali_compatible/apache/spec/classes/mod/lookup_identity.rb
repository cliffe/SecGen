require 'spec_helper'

describe 'apache::mod::lookup_identity', :type => :class do
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
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_package("libapache2-mod-lookup-identity") }
      it { is_expected.to contain_apache__mod('lookup_identity') }
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
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_package("mod_lookup_identity") }
      it { is_expected.to contain_apache__mod('lookup_identity') }
    end # Redhat
  end
end
