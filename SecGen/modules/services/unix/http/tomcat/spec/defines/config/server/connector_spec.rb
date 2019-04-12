require 'spec_helper'

describe 'tomcat::config::server::connector', :type => :define do
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
    'HTTP/1.1'
  end
  context 'set all the things' do
    let :params do
      {
        :port                  => '8180',
        :catalina_base         => '/opt/apache-tomcat/test',
        :protocol              => 'AJP/1.3',
        :parent_service        => 'Catalina2',
        :server_config         => '/opt/apache-tomcat/server.xml',
        :additional_attributes => {
          'redirectPort'      => '8543',
          'connectionTimeout' => '20000',
          'spaces'            => 'foo bar',
        },
        :attributes_to_remove  => [
          'foo',
          'bar',
          'baz'
        ],
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-Catalina2-connector-8180').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/port 8180',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/protocol AJP/1.3',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/redirectPort \'8543\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/connectionTimeout \'20000\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/spaces \'foo bar\'',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/foo',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/bar',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/baz',
      ],
    )
    }
  end
  context 'set all the things with purge_connectors' do
    let :params do
      {
        :port                  => '8180',
        :catalina_base         => '/opt/apache-tomcat/test',
        :protocol              => 'AJP/1.3',
        :purge_connectors      => true,
        :parent_service        => 'Catalina2',
        :additional_attributes => {
          'redirectPort'      => '8543',
          'connectionTimeout' => '20000',
        },
        :attributes_to_remove  => [
          'foo',
          'bar',
          'baz'
        ],
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-Catalina2-connector-8180'
).with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server//Connector[#attribute/protocol=\'AJP/1.3\'][#attribute/port!=\'8180\']',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/port 8180',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/protocol AJP/1.3',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/redirectPort \'8543\'',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/connectionTimeout \'20000\'',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/foo',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/bar',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/port=\'8180\']/#attribute/baz',
      ],
    )
    }
  end
  context 'remove connector' do
    let :params do
      {
        :catalina_base    => '/opt/apache-tomcat/test',
        :connector_ensure => 'absent',
        :port             => '8180',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-Catalina-connector-8180').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Catalina\']/Connector[#attribute/port=\'8180\']',
      ],
    )
    }
  end
  context 'remove connector no port' do
    let :params do
      {
        :catalina_base    => '/opt/apache-tomcat/test',
        :connector_ensure => 'absent',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-Catalina-connector-').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Catalina\']/Connector[#attribute/protocol=\'HTTP/1.1\']',
      ],
    )
    }
  end
  context 'remove connector with purge_connectors' do
    let :params do
      {
        :catalina_base    => 'opt/apache-tomcat/test',
        :connector_ensure => 'absent',
        :purge_connectors => true,
      }
    end
    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, /\$connector_ensure must be set to 'true' or 'present' to use \$purge_connectors/)
    end
  end
  context 'two connectors with same protocol' do
    let :pre_condition do
      'class { "tomcat": }
      tomcat::config::server::connector { "temp":
        protocol => "HTTP/1.1",
        port     => "443",
      }
      '
    end
    let :params do
      {
        :port => '8180',
      }
    end
    it { is_expected.to compile }
  end
  describe 'failing tests' do
    context 'bad connector_ensure' do
      let :params do
        {
          :connector_ensure => 'foo',
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
          :additional_attributes => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /is not a Hash/)
      end
    end
    context 'no port' do
      let :params do
        {
          :catalina_base => '/opt/apache-tomcat/test',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error)
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
