require 'spec_helper'

describe 'tomcat::config::server::listener', :type => :define do
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
    'JmxRemoteLifecycleListener'
  end
  context 'Add Listener' do
    let :params do
      {
         :catalina_base         => '/opt/apache-tomcat/test',
         :class_name            => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
         :listener_ensure       => 'present',
         :server_config         => '/opt/apache-tomcat/server.xml',
         :additional_attributes => {
           'rmiRegistryPortPlatform' => '10001',
           'rmiServerPortPlatform'   => '10002',
           'spaces'                  => 'foo bar',
         },
         :attributes_to_remove  => [
           'foo',
           'bar',
           'baz',
         ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test----listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/className org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
        'set Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/rmiRegistryPortPlatform \'10001\'',
        'set Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/rmiServerPortPlatform \'10002\'',
        'set Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/spaces \'foo bar\'',
        'rm Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/foo',
        'rm Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/bar',
        'rm Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/baz',
      ]
    )
    }
  end
  context 'No class_name' do
    let :title do
      'org.apache.catalina.core.AprLifecycleListener'
    end
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :listener_ensure       => 'present',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test----listener-org.apache.catalina.core.AprLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Listener[#attribute/className=\'org.apache.catalina.core.AprLifecycleListener\']/#attribute/className org.apache.catalina.core.AprLifecycleListener',
      ]
    )
    }
  end
  context '$parent_engine, no $parent_service' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :listener_ensure       => 'present',
        :parent_engine         => 'default',
        :class_name            => 'org.apache.catalina.core.AprLifecycleListener',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-default--listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'default\']/Listener[#attribute/className=\'org.apache.catalina.core.AprLifecycleListener\']/#attribute/className org.apache.catalina.core.AprLifecycleListener',
      ]
    )
    }
  end
  context '$parent_engine' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :listener_ensure       => 'present',
        :parent_engine         => 'default',
        :parent_service        => 'Catalina2',
        :class_name            => 'org.apache.catalina.core.AprLifecycleListener',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2-default--listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine[#attribute/name=\'default\']/Listener[#attribute/className=\'org.apache.catalina.core.AprLifecycleListener\']/#attribute/className org.apache.catalina.core.AprLifecycleListener',
      ]
    )
    }
  end
  context '$parent_host, no $parent_engine or $parent_service' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :listener_ensure       => 'present',
        :parent_host           => 'localhost',
        :class_name            => 'org.apache.catalina.core.AprLifecycleListener',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina--localhost-listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Listener[#attribute/className=\'org.apache.catalina.core.AprLifecycleListener\']/#attribute/className org.apache.catalina.core.AprLifecycleListener',
      ]
    )
    }
  end
  context '$parent_host, no $parent_engine' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :listener_ensure       => 'present',
        :parent_host           => 'localhost',
        :parent_service        => 'Catalina2',
        :class_name            => 'org.apache.catalina.core.AprLifecycleListener',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2--localhost-listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Listener[#attribute/className=\'org.apache.catalina.core.AprLifecycleListener\']/#attribute/className org.apache.catalina.core.AprLifecycleListener',
      ]
    )
    }
  end
  context '$parent_host' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :listener_ensure       => 'present',
        :parent_engine         => 'default',
        :parent_host           => 'localhost',
        :parent_service        => 'Catalina2',
        :class_name            => 'org.apache.catalina.core.AprLifecycleListener',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2-default-localhost-listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine[#attribute/name=\'default\']/Host[#attribute/name=\'localhost\']/Listener[#attribute/className=\'org.apache.catalina.core.AprLifecycleListener\']/#attribute/className org.apache.catalina.core.AprLifecycleListener',
      ]
    )
    }
  end
  context 'Remove Listener' do
    let :params do
      {
        :catalina_base   => '/opt/apache-tomcat/test',
        :class_name      => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
        :listener_ensure => 'absent',
      }
    end 
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test----listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Listener[#attribute/className=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']'
      ]
    )
    }
  end
  context 'Failing Tests' do
    context 'Bad listener_ensure' do
      let :params do
        {
          :listener_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'Bad additional_attributes' do
      let :params do
        {
          :additional_attributes => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /is not a Hash/)
      end
    end
    context 'Bad attributes_to_remove' do
      let :params do
        {
          :attributes_to_remove => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /is not an Array/)
      end
    end
    context 'old augeas' do
      let :facts do
        {
          :osfamily      => 'Debian',
          :augeasversion => '0.10.0'
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
