require 'spec_helper'

describe 'tomcat::war', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily         => 'Debian',
      :staging_http_get => 'curl',
    }
  end
  let :title do
    'sample.war'
  end
  context 'basic deployment' do
    let :params do
      {
        :war_source => '/tmp/sample.war',
      }
    end
    it { is_expected.to contain_staging__file('sample.war').with(
      'source' => '/tmp/sample.war',
      'target' => '/opt/apache-tomcat/webapps/sample.war',
    )
    }
  end
  context 'basic undeployment' do
    let :params do
      {
        :war_ensure => 'absent'
      }
    end
    it { is_expected.to contain_file('/opt/apache-tomcat/webapps/sample.war').with(
      'ensure' => 'absent',
      'force'  => 'false',
    )
    }
    it { is_expected.to contain_file('/opt/apache-tomcat/webapps/sample').with(
      'ensure' => 'absent',
      'force'  => 'true',
    )
    }
  end
  context 'set everything' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :app_base      => 'webapps2',
        :war_ensure    => 'true',
        :war_name      => 'sample2.war',
        :war_source    => '/tmp/sample.war',
      }
    end
    it { is_expected.to contain_staging__file('sample.war').with(
      'source' => '/tmp/sample.war',
      'target' => '/opt/apache-tomcat/test/webapps2/sample2.war',
    )
    }
  end
  context 'set deployment_path' do
    let :params do
      {
        :deployment_path => '/opt/apache-tomcat/webapps3',
        :war_source      => '/tmp/sample.war',
      }
    end
    it { is_expected.to contain_staging__file('sample.war').with(
      'source' => '/tmp/sample.war',
      'target' => '/opt/apache-tomcat/webapps3/sample.war',
    )
    }
  end
  context 'war_purge is false' do
    let :params do
      {
        :war_ensure => 'absent',
        :war_purge  => false,
      }
    end
    it { is_expected.to contain_file('/opt/apache-tomcat/webapps/sample.war').with(
      'ensure' => 'absent',
      'force'  => 'false',
    )
    }
    it { is_expected.to_not contain_file('/opt/apache-tomcat/webapps/sample').with(
      'ensure' => 'absent',
      'force'  => 'true',
    )
    }
  end
  describe 'failing tests' do
    context 'bad war name' do
      let :params do
        {
          :war_name   => 'foo',
          :war_source => '/tmp/sample.war',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad ensure' do
      let :params do
        {
          :war_ensure => 'foo',
          :war_source => '/tmp/sample.war',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad purge' do
      let :params do
        {
          :war_ensure => 'absent',
          :war_purge  => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /is not a boolean/)
      end
    end
    context 'invalid source' do
      let :params do
        {
          :war_source => 'foo',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /not recognize source/)
      end
    end
    context 'no source' do
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /\$war_source must be specified/)
      end
    end
    context 'both app_base and deployment_path' do
      let :params do
        {
          :war_source      => '/tmp/sample.war',
          :app_base        => 'webapps2',
          :deployment_path => '/opt/apache-tomcat/webapps3',
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /Only one of \$app_base and \$deployment_path can be specified/)
      end
    end
  end
end
