require 'spec_helper'

describe 'tomcat::config::server::realm', :type => :define do
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
    'org.apache.catalina.realm.JNDIRealm'
  end
  context 'Add Realm' do
    let :params do
      {
         :class_name            => 'org.apache.catalina.realm.JNDIRealm',
         :catalina_base         => '/opt/apache-tomcat/test',
         :realm_ensure          => 'present',
         :server_config         => '/opt/apache-tomcat/server.xml',
         :additional_attributes => {
          'connectionURL' => 'ldap://localhost',
          'roleName'      => 'cn',
          'roleSearch'    => 'member={0}',
          'spaces'        => 'foo bar',
         },
         :attributes_to_remove  => [
           'foo',
           'bar',
           'baz',
         ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/connectionURL 'ldap://localhost'",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/roleName 'cn'",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/roleSearch 'member={0}'",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/spaces 'foo bar'",
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/foo",
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/bar",
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/baz",
      ]
    )
    }
  end
  context 'Purge Realms' do
    let :params do
      {
        :purge_realms => true,
        :class_name => 'org.apache.catalina.realm.JNDIRealm',
        :catalina_base => '/opt/apache-tomcat/test',
        :realm_ensure => 'true',
        :additional_attributes => {
          'connectionURL' => 'ldap://localhost',
          'roleName'      => 'cn',
        },
        :attributes_to_remove  => [
          'foo',
          'bar',
        ],
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        "rm //Realm//Realm",
        "rm //Context//Realm",
        "rm //Host//Realm",
        "rm //Engine//Realm",
        "rm //Server//Realm",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/connectionURL 'ldap://localhost'",
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/roleName 'cn'",
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/foo",
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/bar",
      ]
    )
    }
  end
  context 'No class_name' do
    let :title do
      'org.apache.catalina.realm.JNDIRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :realm_ensure => 'present',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
      ]
    )
    }
  end
  context 'Duplicate class_name' do
    let :title do
      'first'
    end
    let :pre_condition do
      <<-END
      tomcat::config::server::realm { 'second':
        class_name    => 'org.apache.catalina.realm.JNDIRealm',
        catalina_base => '/opt/apache-tomcat/test',
        realm_ensure  => 'present',
      }
      END
    end
    let :params do
      {
        :class_name => 'org.apache.catalina.realm.JNDIRealm',
        :catalina_base => '/opt/apache-tomcat/test',
        :realm_ensure => 'present',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-first').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
      ]
    )
    }
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-second').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
      ]
    )
    }
  end
  context '$realm_ensure absent' do
    let :title do
      'org.apache.catalina.realm.LockOutRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :realm_ensure => 'absent',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-org.apache.catalina.realm.LockOutRealm').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']",
      ]
    )
    }
  end
  context '$realm_ensure false' do
    let :title do
      'org.apache.catalina.realm.LockOutRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :realm_ensure => 'false',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina---realm-org.apache.catalina.realm.LockOutRealm').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        "rm Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']",
      ]
    )
    }
  end
  context 'Add Realm with $parent_service and $parent_engine' do
    let :title do
      'org.apache.catalina.realm.JNDIRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :parent_service => 'NewService',
        :parent_engine => 'AnotherEngine',
        :realm_ensure => 'present',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-NewService-AnotherEngine---realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens' => 'Xml.lns',
       'incl' => '/opt/apache-tomcat/test/conf/server.xml',
       'changes' => [
         "set Server/Service[#attribute/name='NewService']/Engine[#attribute/name='AnotherEngine']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
       ]
    )
    }
  end
  context 'Add Realm with $parent_host' do
    let :title do
      'org.apache.catalina.realm.JNDIRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :parent_host => 'localhost',
        :realm_ensure => 'present',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina-localhost--realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens' => 'Xml.lns',
       'incl' => '/opt/apache-tomcat/test/conf/server.xml',
       'changes' => [
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Host[#attribute/name='localhost']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
       ]
    )
    }
  end
  context 'Add Realm with $parent_host and $parent_realm' do
    let :title do
      'org.apache.catalina.realm.JNDIRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :parent_host => 'localhost',
        :parent_realm => 'org.apache.catalina.realm.LockOutRealm',
        :realm_ensure => 'present',
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina-localhost-org.apache.catalina.realm.LockOutRealm-realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens' => 'Xml.lns',
       'incl' => '/opt/apache-tomcat/test/conf/server.xml',
       'changes' => [
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Host[#attribute/name='localhost']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
       ]
    )
    }
  end
  context 'Add Realm with $parent_realm only' do
    let :title do
      'org.apache.catalina.realm.JNDIRealm'
    end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :parent_realm => 'org.apache.catalina.realm.LockOutRealm',
        :realm_ensure => 'present',
         :additional_attributes => {
          'connectionURL' => 'ldap://localhost',
          'roleName'      => 'cn',
          'roleSearch'    => 'member={0}',
          'spaces'        => 'foo bar',
         },
      }
    end
    it { is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina-Catalina--org.apache.catalina.realm.LockOutRealm-realm-org.apache.catalina.realm.JNDIRealm').with(
      'lens' => 'Xml.lns',
       'incl' => '/opt/apache-tomcat/test/conf/server.xml',
       'changes' => [
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/className org.apache.catalina.realm.JNDIRealm",
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/connectionURL 'ldap://localhost'",
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/roleName 'cn'",
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/roleSearch 'member={0}'",
         "set Server/Service[#attribute/name='Catalina']/Engine[#attribute/name='Catalina']/Realm[#attribute/className='org.apache.catalina.realm.LockOutRealm']/Realm[#attribute/className='org.apache.catalina.realm.JNDIRealm']/#attribute/spaces 'foo bar'",
       ]
    )
    }
  end
  context 'Failing Tests' do
    context 'Bad realm_ensure' do
      let :params do
        {
          :realm_ensure => 'foo',
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
    context 'Bad purge_realms' do
      let :params do
        {
          :purge_realms => 'true',
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /is not a boolean/)
      end
    end
    context 'Purge realms with $realm_ensure => false' do
      let :params do
        {
          :realm_ensure => 'false',
          :purge_realms => true,
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /\$realm_ensure must be set to 'true' or 'present' to use \$purge_realms/)
      end
    end
    context 'Purge realms with $realm_ensure => absent' do
      let :params do
        {
          :realm_ensure => 'absent',
          :purge_realms => true,
        }
      end
      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, /\$realm_ensure must be set to 'true' or 'present' to use \$purge_realms/)
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
        }.to raise_error(Puppet::Error, /configurations require Augeas >= 1.0.0/)
      end
    end
  end
end
