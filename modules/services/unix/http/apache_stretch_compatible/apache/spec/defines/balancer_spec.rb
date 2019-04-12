require 'spec_helper'

describe 'apache::balancer', :type => :define do
  let :title do
    'myapp'
  end
  let :facts do
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '6',
      :lsbdistcodename        => 'squeeze',
      :id                     => 'root',
      :concat_basedir         => '/dne',
      :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      :kernel                 => 'Linux',
      :is_pe                  => false,
    }
  end
  describe 'apache pre_condition with defaults' do
    let :pre_condition do
      'include apache'
    end
    describe "accept a target parameter and use it" do
      let :params do
        {
          :target => '/tmp/myapp.conf'
        }
      end
      it { should contain_concat('apache_balancer_myapp').with({
        :path => "/tmp/myapp.conf",
      })}
      it { should_not contain_apache__mod('slotmem_shm') }
      it { should_not contain_apache__mod('lbmethod_byrequests') }
    end
    context "on jessie" do
      let(:facts) { super().merge({
        :operatingsystemrelease => '8',
        :lsbdistcodename        => 'jessie',
      }) }
      it { should contain_apache__mod('slotmem_shm') }
      it { should contain_apache__mod('lbmethod_byrequests') }
    end
  end
  describe 'apache pre_condition with conf_dir set' do 
    let :pre_condition do
      'class{"apache":
          confd_dir => "/junk/path"
       }'
    end
    it { should contain_concat('apache_balancer_myapp').with({
      :path => "/junk/path/balancer_myapp.conf",
    })}
  end

  describe 'with lbmethod and with apache::mod::proxy_balancer::apache_version set' do
    let :pre_condition do
      'class{"apache::mod::proxy_balancer":
          apache_version => "2.4"
       }'
    end
    let :params do
      {
        :proxy_set => {
          'lbmethod' => 'bytraffic',
        },
      }
    end
    it { should contain_apache__mod('slotmem_shm') }
    it { should contain_apache__mod('lbmethod_bytraffic') }
  end
end
