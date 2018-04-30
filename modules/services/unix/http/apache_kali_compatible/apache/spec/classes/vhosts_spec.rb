require 'spec_helper'

describe 'apache::vhosts', :type => :class do
  context 'on all OSes' do
    let :facts do
      {
          :id                     => 'root',
          :kernel                 => 'Linux',
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
      }
    end
    context 'with custom vhosts parameter' do
      let :params do {
          :vhosts => {
              'custom_vhost_1' => {
                  'docroot' => '/var/www/custom_vhost_1',
                  'port' => '81',
              },
              'custom_vhost_2' => {
                  'docroot' => '/var/www/custom_vhost_2',
                  'port' => '82',
              },
          },
      }
      end
      it { is_expected.to contain_apache__vhost('custom_vhost_1') }
      it { is_expected.to contain_apache__vhost('custom_vhost_2') }
    end
  end
end
