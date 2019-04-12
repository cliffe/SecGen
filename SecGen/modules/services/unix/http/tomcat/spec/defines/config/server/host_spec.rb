require 'spec_helper'

describe 'tomcat::config::server::host', :type => :define do
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
    'localhost'
  end
  context 'defaults' do
    let :params do
      {
        :app_base => 'webapps'
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina-host-localhost').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/#attribute/name localhost',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/#attribute/appBase webapps',
      ]
    )
    }
  end
  context 'set all the things' do
    let :params do
      {
        :app_base              => 'webapps2',
        :catalina_base         => '/opt/apache-tomcat/test',
        :host_ensure           => 'true',
        :host_name             => 'test.example.com',
        :parent_service        => 'Catalina2',
        :server_config         => '/opt/apache-tomcat/server.xml',
        :additional_attributes => {
          'autoDeploy' => 'false',
          'unpackWARs' => 'false',
          'spaces'     => 'foo bar',
        },
        :attributes_to_remove  => [
          'foo',
          'bar',
          'baz',
        ],
        :aliases              => [
          'able',
          'baker',
          'charlie',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2-host-localhost').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/name test.example.com',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/appBase webapps2',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/autoDeploy \'false\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/unpackWARs \'false\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/spaces \'foo bar\'',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/foo',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/bar',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/#attribute/baz',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/Alias',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/Alias[last()+1]/#text \'able\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/Alias[last()+1]/#text \'baker\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'test.example.com\']/Alias[last()+1]/#text \'charlie\'',
      ]
    )
    }
  end
  context 'empty array of aliases removes old aliases and does not add any' do
    let :params do
      {
        :app_base => 'webapps',
        :aliases  => [],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina-host-localhost').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/#attribute/name localhost',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/#attribute/appBase webapps',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Alias',
      ]
    )
    }
  end
  context 'remove the host' do
    let :params do
      {
        :host_ensure => 'false'
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat-Catalina-host-localhost').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']'
      ]
    )
    }
  end
  describe 'failing tests' do
    context 'no app_base' do
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /\$app_base must be specified/)
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
        }.to raise_error(Puppet::Error, /is not a Hash/)
      end
    end
    context 'invalid host_ensure' do
      let :params do
        {
          :host_ensure => 'foo'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'invalid aliases' do
      let :params do
        {
          :app_base => 'webapps',
          :aliases => 'not_an_array',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /is not an Array/)
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
