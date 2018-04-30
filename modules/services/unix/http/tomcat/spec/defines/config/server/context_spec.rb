require 'spec_helper'

describe 'tomcat::config::server::context', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily      => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'exampleapp.war'
  end
  context 'Add Context' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/exampleapp',
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_service        => 'Catalina',
        :parent_engine         => 'Catalina',
        :parent_host           => 'localhost',
        :server_config         => '/opt/apache-tomcat/server.xml',
        :additional_attributes => {
          'path' => '/myapp',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina-Catalina-localhost-context-exampleapp.war').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/#attribute/docBase myapp.war',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/#attribute/path \'/myapp\'',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/#attribute/foobar',
      ]
    )
    }
  end
  context 'No doc_base' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/exampleapp',
        :context_ensure        => 'present',
        :parent_service        => 'Catalina',
        :parent_engine         => 'Catalina',
        :parent_host           => 'localhost',
        :additional_attributes => {
          'path' => '/exampleapp',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina-Catalina-localhost-context-exampleapp.war').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/#attribute/docBase exampleapp.war',
        'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/#attribute/path \'/exampleapp\'',
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/#attribute/foobar',
      ]
    )
    }
  end
  context 'context with $parent_service' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/exampleapp',
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_service        => 'test',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-test---context-exampleapp.war').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'test\']/Engine/Host/Context[#attribute/docBase=\'myapp.war\']/#attribute/docBase myapp.war',
      ]
    )
    }
  end
  context 'context with $parent_host' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/exampleapp',
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_host           => 'localhost',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina--localhost-context-exampleapp.war').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']/#attribute/docBase myapp.war',
      ]
    )
    }
  end
  context '$parent_engine, no $parent_host' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/exampleapp',
        :context_ensure        => 'present',
        :doc_base              => 'myapp.war',
        :parent_engine         => 'Catalina',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina---context-exampleapp.war').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host/Context[#attribute/docBase=\'myapp.war\']/#attribute/docBase myapp.war',
      ]
    )
    }
  end
  context 'Remove Context' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/exampleapp',
        :context_ensure        => 'absent',
        :doc_base              => 'myapp.war',
        :parent_service        => 'Catalina',
        :parent_engine         => 'Catalina',
        :parent_host           => 'localhost',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina-Catalina-localhost-context-exampleapp.war').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'myapp.war\']',
      ]
    )
    }
  end
  describe 'Failing Tests' do
    context 'bad context_ensure' do
      let :params do
        {
          :context_ensure => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
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
