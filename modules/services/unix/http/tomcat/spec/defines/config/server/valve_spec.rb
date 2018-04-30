require 'spec_helper'

describe 'tomcat::config::server::valve', :type => :define do
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
    'org.apache.catalina.AccessLog'
  end
  context 'default' do
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina--valve-org.apache.catalina.AccessLog').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/conf/server.xml',
      'changes' => ['set Server/Service[#attribute/name=\'Catalina\']/Engine/Valve[#attribute/className=\'org.apache.catalina.AccessLog\']/#attribute/className org.apache.catalina.AccessLog'],
    )
    }
  end
  context 'set all the things' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :class_name            => 'foo',
        :parent_host           => 'localhost',
        :parent_service        => 'Catalina2',
        :parent_context        => '/var/www/foo',
        :server_config         => '/opt/apache-tomcat/server.xml',
        :additional_attributes => {
          'suffix'    => '.txt',
          'directory' => 'logs',
          'spaces'    => 'foo bar',
        },
        :attributes_to_remove  => ['foo', 'bar']
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2-localhost-valve-org.apache.catalina.AccessLog').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'foo\']/#attribute/className foo',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'foo\']/#attribute/suffix \'.txt\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'foo\']/#attribute/directory \'logs\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'foo\']/#attribute/spaces \'foo bar\'',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'foo\']/#attribute/foo',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'foo\']/#attribute/bar',
      ]
    )
    }
  end
  context 'remove the valve' do
    let :params do
      {
        :valve_ensure => 'false'
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina--valve-org.apache.catalina.AccessLog').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/conf/server.xml',
      'changes' => 'rm Server/Service[#attribute/name=\'Catalina\']/Engine/Valve[#attribute/className=\'org.apache.catalina.AccessLog\']',
    )
    }
  end
  describe 'failing tests' do
    context 'bad valve_ensure' do
      let :params do
        {
          :valve_ensure => 'foo'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad additional_attributes' do
      let :params do
        {
          :additional_attributes => 'foo'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /not a Hash/)
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
