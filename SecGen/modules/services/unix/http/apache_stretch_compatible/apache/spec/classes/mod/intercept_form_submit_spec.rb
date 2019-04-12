require 'spec_helper'

describe 'apache::mod::intercept_form_submit', :type => :class do
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
      it { is_expected.to contain_package("libapache2-mod-intercept-form-submit") }
      it { is_expected.to contain_apache__mod('intercept_form_submit') }
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
      it { is_expected.to contain_package("mod_intercept_form_submit") }
      it { is_expected.to contain_apache__mod('intercept_form_submit') }
    end # Redhat
  end
end
