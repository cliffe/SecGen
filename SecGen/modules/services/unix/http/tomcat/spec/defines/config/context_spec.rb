require 'spec_helper'

describe 'tomcat::config::context', :type => :define do
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
    'Context'
  end
  context 'Set Context Wathced resource' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test'
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/WatchedResource/#text "WEB-INF/web.xml"',
      ]
    )
    }
  end

  describe 'failing tests' do
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
