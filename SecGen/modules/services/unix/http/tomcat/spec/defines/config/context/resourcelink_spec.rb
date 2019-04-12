require 'spec_helper'

describe 'tomcat::config::context::resourcelink', :type => :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'linkToGlobalResource'
  end
  context 'Add ResourceLink' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :resourcelink_type     => 'java',
        :additional_attributes => {
          'factory' => 'javax.naming.spi.ObjectFactory',
          'global'  => 'simpleValue',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resourcelink-linkToGlobalResource').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/name linkToGlobalResource',
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/type java',
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/factory \'javax.naming.spi.ObjectFactory\'',
        'set Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/global \'simpleValue\'',
        'rm Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']/#attribute/foobar',
        ]
      )
    }
  end
  context 'Remove ResourceLink' do
    let :params do
      {
        :catalina_base   => '/opt/apache-tomcat/test',
        :ensure => 'absent',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resourcelink-linkToGlobalResource').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'rm Context/ResourceLink[#attribute/name=\'linkToGlobalResource\']',
        ]
      )
    }
  end
end
