require 'spec_helper'

describe 'tomcat::config::server::engine', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'Catalina'
  end
  context 'default' do
    let :params do
      {
        :default_host => 'localhost',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina-engine').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/name Catalina',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/defaultHost localhost',
      ]
    )
    }
  end
  context 'set all the things' do
    let :params do
      {
        :default_host               => 'localhost',
        :catalina_base              => '/opt/apache-tomcat/test',
        :background_processor_delay => '10',
        :class_name                 => 'foo',
        :engine_name                => 'Catalina2',
        :jvm_route                  => 'bar',
        :parent_service             => 'Catalina2',
        :start_stop_threads         => '200',
        :server_config              => '/opt/apache-tomcat/server.xml',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2-engine').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/#attribute/name Catalina2',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/#attribute/defaultHost localhost',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/#attribute/backgroundProcessorDelay 10',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/#attribute/className foo',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/#attribute/jvmRoute bar',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/#attribute/startStopThreads 200',
      ]
    )
    }
  end
  context 'remove all the things' do
    let :params do
      {
        :default_host => 'localhost',
        :background_processor_delay_ensure => 'false',
        :class_name_ensure => 'absent',
        :jvm_route_ensure => 'false',
        :start_stop_threads_ensure => 'absent',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina-engine').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/name Catalina',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/defaultHost localhost',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/backgroundProcessorDelay',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/className',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/jvmRoute',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine/#attribute/startStopThreads',
      ]
    )
    }
  end
  describe 'failing tests' do
    context 'bad background_processor_delay ensure' do
      let :params do
        {
          :default_host                      => 'localhost',
          :background_processor_delay_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad class_name_ensure' do
      let :params do
        {
          :default_host      => 'localhost',
          :class_name_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad jvm_route_ensure' do
      let :params do
        {
          :default_host     => 'localhost',
          :jvm_route_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad start_stop_threads ensure' do
      let :params do
        {
          :default_host              => 'localhost',
          :start_stop_threads_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'old augeas' do
      let :facts do
        {
          :osfamily      => 'Debian',
          :augeasversion => '0.10.0'
        }
      end
      let :params do
        {
          :default_host              => 'localhost',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /configurations require Augeas/)
      end
    end
  end
end
