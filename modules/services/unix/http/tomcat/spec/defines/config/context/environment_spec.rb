require 'spec_helper'

describe 'tomcat::config::context::environment', :type => :define do
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
    'maxExemptions'
  end
  context 'Add Environment' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/foo',
        :environment_name      => 'maxExemptions',
        :type                  => 'java.lang.Integer',
        :value                 => '10',
        :additional_attributes => {
          'foo' => 'bar',
          'bar' => 'foo',
        },
        :attributes_to_remove  => [
          'foobar',
          'barfoo',
        ]
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-environment-maxExemptions').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
      'changes' => [
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/type java.lang.Integer',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/value 10',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/override',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/description',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/foo \'bar\'',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/bar \'foo\'',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/foobar',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/barfoo',
      ]
    )
    }
  end
  context 'Remove Environment' do
   let :params do
     {
       :catalina_base => '/opt/apache-tomcat/foo',
       :ensure        => 'absent',
     }
   end
   it { is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-environment-maxExemptions').with(
     'lens'    => 'Xml.lns',
     'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
     'changes' => [
       'rm Context/Environment[#attribute/name=\'maxExemptions\']',
       ]
     )
   }
  end
  context 'No environment_name' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/foo',
        :type          => 'java.lang.Integer',
        :value         => '10',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-environment-maxExemptions').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
      'changes' => [
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/type java.lang.Integer',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/value 10',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/override',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/description',
        ]
      )
    }
  end
  context 'Set override' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/foo',
        :type          => 'java.lang.Integer',
        :value         => '10',
        :override      => 'true',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-environment-maxExemptions').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
      'changes' => [
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/type java.lang.Integer',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/value 10',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/override true',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/description',
        ]
      )
    }
  end
  context 'Set description' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/foo',
        :type          => 'java.lang.Integer',
        :value         => '10',
        :description   => 'foo bar',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-environment-maxExemptions').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
      'changes' => [
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/type java.lang.Integer',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/value 10',
        'rm Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/override',
        'set Context/Environment[#attribute/name=\'maxExemptions\']/#attribute/description \'foo bar\'',
        ]
      )
    }
  end
  context 'Failing Tests' do
    context 'Bad ensure' do
      let :params do
        {
          :ensure        => 'foobar',
          :catalina_base => '/opt/apache-tomcat/foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'Empty catalina_base' do
      let :params do
        {
          :catalina_base => '',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /is not an absolute path/)
      end
    end
    context 'No type' do
      let :params do
        {
          :catalina_base => '/opt/apache-tomcat/foo',
          :value         => '10',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /\$type must be specified/)
      end
    end
    context 'No value' do
      let :params do
        {
          :catalina_base => '/opt/apache-tomcat/foo',
          :type          => 'java.lang.Integer',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /\$value must be specified/)
      end
    end
    context 'Bad override' do
      let :params do
        {
          :catalina_base => '/opt/apache-tomcat/foo',
          :type          => 'java.lang.Integer',
          :value         => '10',
          :override      => 'foobar',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /\$override must be true or false/)
      end
    end
  end
end
