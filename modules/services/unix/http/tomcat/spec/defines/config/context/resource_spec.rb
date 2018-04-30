require 'spec_helper'

describe 'tomcat::config::context::resource', :type => :define do
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
    'jdbc'
  end
  context 'Add Resource' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :resource_type         => 'net.sourceforge.jtds.jdbcx.JtdsDataSource',
        :additional_attributes => {
          'auth'            => 'Container',
          'closeMethod'     => 'closeMethod',
          'validationQuery' => 'getdate()',
          'description'     => 'description',
          'scope'           => 'Shareable',
          'singleton'       => 'true',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resource-jdbc').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/name jdbc',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/type net.sourceforge.jtds.jdbcx.JtdsDataSource',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/auth \'Container\'',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/closeMethod \'closeMethod\'',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/validationQuery \'getdate()\'',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/description \'description\'',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/scope \'Shareable\'',
        'set Context/Resource[#attribute/name=\'jdbc\']/#attribute/singleton \'true\'',
        'rm Context/Resource[#attribute/name=\'jdbc\']/#attribute/foobar',
        ]
      )
    }
  end
  context 'Remove Resource' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :ensure        => 'absent',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resource-jdbc').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'rm Context/Resource[#attribute/name=\'jdbc\']',
        ]
      )
    }
  end
end
