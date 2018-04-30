require 'spec_helper'

describe 'apache::mod::cluster', :type => :class do
  context 'on a RedHat OS Release 7 with mod version = 1.3.0' do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    let(:params) {
      {
        :allowed_network         => '172.17.0',
        :balancer_name           => 'mycluster',
        :ip                      => '172.17.0.1',
        :version                 => '1.3.0'
      }
    }

    it { is_expected.to contain_class("apache") }
    it { is_expected.to contain_apache__mod('proxy') }
    it { is_expected.to contain_apache__mod('proxy_ajp') }
    it { is_expected.to contain_apache__mod('manager') }
    it { is_expected.to contain_apache__mod('proxy_cluster') }
    it { is_expected.to contain_apache__mod('advertise') }
    it { is_expected.to contain_apache__mod('cluster_slotmem') }

    it { is_expected.to contain_file('cluster.conf') }
  end

  context 'on a RedHat OS Release 7 with mod version > 1.3.0' do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    let(:params) {
      {
        :allowed_network         => '172.17.0',
        :balancer_name           => 'mycluster',
        :ip                      => '172.17.0.1',
        :version                 => '1.3.1'
      }
    }

    it { is_expected.to contain_class('apache') }
    it { is_expected.to contain_apache__mod('proxy') }
    it { is_expected.to contain_apache__mod('proxy_ajp') }
    it { is_expected.to contain_apache__mod('manager') }
    it { is_expected.to contain_apache__mod('proxy_cluster') }
    it { is_expected.to contain_apache__mod('advertise') }
    it { is_expected.to contain_apache__mod('cluster_slotmem') }

    it { is_expected.to contain_file('cluster.conf') }
  end

  context 'on a RedHat OS Release 6 with mod version < 1.3.0' do
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

    let(:params) {
      {
        :allowed_network         => '172.17.0',
        :balancer_name           => 'mycluster',
        :ip                      => '172.17.0.1',
        :version                 => '1.2.0'
      }
    }

    it { is_expected.to contain_class('apache') }
    it { is_expected.to contain_apache__mod('proxy') }
    it { is_expected.to contain_apache__mod('proxy_ajp') }
    it { is_expected.to contain_apache__mod('manager') }
    it { is_expected.to contain_apache__mod('proxy_cluster') }
    it { is_expected.to contain_apache__mod('advertise') }
    it { is_expected.to contain_apache__mod('slotmem') }

    it { is_expected.to contain_file('cluster.conf') }
  end
end
