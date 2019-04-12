require 'spec_helper'

describe 'tomcat::service', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
    }
  end
  let :title do
    'default'
  end
  context 'using jsvc' do
    let :params do
      {
        :use_jsvc => true,
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
    )
    }
  end
  context 'set start/stop with jsvc' do
    let :params do
      {
        :use_jsvc      => true,
        :start_command => '/bin/true',
        :stop_command  => '/bin/true',
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'start'      => '/bin/true',
      'stop'       => '/bin/true',
    )
    }
  end
  context 'using init' do
    let :params do
      {
        :use_init       => true,
        :service_name   => 'tomcat',
        :service_ensure => 'stopped',
      }
    end
    it { is_expected.to contain_service('tomcat').with(
      'hasstatus'  => true,
      'hasrestart' => true,
      'ensure'     => 'stopped'
    )
    }
  end
  context 'using init with $catalina_base' do
    let :params do
      {
        :use_init      => true,
        :service_name  => 'tomcat',
        :catalina_base => '/opt/apache-tomcat/foo',
      }
    end
    # This should throw a warning, but that isn't supported by puppet-rspec
    # so let's just make sure it compiles
    it { is_expected.to compile }
  end
  context "both jsvc and init with $catalina_base" do
    let :params do
      {
        :use_jsvc      => true,
        :use_init      => true,
        :catalina_base => '/opt/apache-tomcat/foo',
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => true,
      'hasrestart' => true,
      'ensure'     => 'running',
      'start'      => 'service tomcat-default start',
      'stop'       => 'service tomcat-default stop',
    )
    }
  end
  context 'set start/stop with init' do
    let :params do
      {
        :use_init      => true,
        :start_command => '/bin/true',
        :stop_command  => '/bin/true',
        :service_name  => 'tomcat',
      }
    end
    it { is_expected.to contain_service('tomcat').with(
      'hasstatus'  => true,
      'hasrestart' => true,
      'ensure'     => 'running',
      'start'      => '/bin/true',
      'stop'       => '/bin/true',
    )
    }
  end
  context "neither jsvc or init" do
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'start'      => "su -s /bin/bash -c 'CATALINA_HOME=/opt/apache-tomcat CATALINA_BASE=/opt/apache-tomcat /opt/apache-tomcat/bin/catalina.sh start' tomcat",
      'stop'       => "su -s /bin/bash -c 'CATALINA_HOME=/opt/apache-tomcat CATALINA_BASE=/opt/apache-tomcat /opt/apache-tomcat/bin/catalina.sh stop' tomcat",
    )
    }
  end
  context "default, set start/stop" do
    let :params do
      {
        :start_command => '/bin/true',
        :stop_command  => '/bin/true',
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'start'      => '/bin/true',
      'stop'       => '/bin/true',
    )
    }
  end

  context "service_enable, set from user" do
    let :params do
      {
        :use_init       => true,
        :service_name   => 'tomcat',
        :service_enable => true,
      }
    end
    it { is_expected.to contain_service('tomcat').with(
      'enable' => true,
    )
    }
  end
  context "service_enable, set true from defaults" do
    let :params do
      {
        :use_init       => true,
        :service_name   => 'tomcat',
        :service_ensure => 'running',
      }
    end
    it { is_expected.to contain_service('tomcat').with(
      'hasstatus'  => true,
      'hasrestart' => true,
      'ensure'     => 'running',
      'enable'     => true,
    )
    }
  end
  context "service_enable, set undef from defaults" do
    let :params do
      {
        :use_init       => false,
        :service_ensure => 'running',
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'enable'     => nil,
    )
    }
  end
  context "service_enable, error thrown if use_init is false" do
    let :params do
      {
        :use_init => false,
        :service_enable => true,
      }
    end
    # This should throw a warning, but that isn't supported by puppet-rspec
    # so let's just make sure it compiles
    it { is_expected.to compile }
  end
  describe 'failing tests' do
    context "bad use_jsvc" do
      let :params do
        {
          :use_jsvc => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /not a boolean/)
      end
    end
    context "bad use_init" do
      let :params do
        {
          :use_init => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /not a boolean/)
      end
    end
    context "java_home without use_jsvc warning" do
      let :params do
        {
          :java_home => 'foo',
        }
      end

      it { is_expected.to compile }
    end
    context "java_home with start_command" do
      let :params do
        {
          :java_home     => 'foo',
          :start_command => '/bin/true',
        }
      end

      it { is_expected.to compile }
    end
  end
end
