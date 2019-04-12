require 'spec_helper'

describe 'tomcat::instance', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :default_facts do
    {
      :osfamily         => 'Debian',
      :staging_http_get => 'curl',
      :path             => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'default'
  end
  context 'default install from source' do
    let :facts do default_facts end
    let :params do
      {
        :source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end
    it { is_expected.to contain_user("tomcat").with(
      'ensure' => 'present',
      'gid'    => 'tomcat',
    ) }
    it { is_expected.to contain_group("tomcat").with(
      'ensure' => 'present'
    ) }
    it { is_expected.to contain_file("/opt/apache-tomcat").with(
      'ensure' => 'directory',
      'owner'  => 'tomcat',
      'group'  => 'tomcat',
      )
    }
    it { is_expected.to contain_staging__file('apache-tomcat-8.0.8.tar.gz') }
    it { is_expected.to contain_staging__extract('default-apache-tomcat-8.0.8.tar.gz').with(
      'target' => '/opt/apache-tomcat',
      'user'   => 'tomcat',
      'group'  => 'tomcat',
      'strip'  => 1,
    )
    }
  end
  context 'install from source, different catalina_base' do
    let :facts do default_facts end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test-tomcat',
        :source_url    => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end
    it { is_expected.to contain_staging__file('apache-tomcat-8.0.8.tar.gz') }
    it { is_expected.to contain_staging__extract('default-apache-tomcat-8.0.8.tar.gz').with(
      'target' => '/opt/apache-tomcat/test-tomcat',
      'user'   => 'tomcat',
      'group'  => 'tomcat',
      'strip'  => 1,
    )
    }
    it { is_expected.to contain_file('/opt/apache-tomcat/test-tomcat').with(
      'ensure' => 'directory',
      'owner'  => 'tomcat',
      'group'  => 'tomcat',
    )
    }
  end
  context "install from package" do
    let :facts do default_facts end
    let :params do
      {
        :install_from_source => false,
        :package_name        => 'tomcat',
      }
    end
    it { is_expected.to contain_package('tomcat') }
    context "with additional package_options set" do
      let :params do
        {
          :install_from_source => false,
          :package_name        => 'tomcat',
          :package_options     => [ '/S' ],
        }
      end
      it {
        is_expected.to contain_package('tomcat').with(
          'install_options' => [ '/S' ],
        )
      }
    end
  end
  context "install from package, set $catalina_base" do
    let :facts do default_facts end
    let :params do
      {
        :install_from_source => false,
        :package_name        => 'tomcat',
        :catalina_home       => '/opt/apache-tomcat',
        :catalina_base       => '/opt/apache-tomcat/foo',
      }
    end

    # This is supposed to generate a warning, but checking for that isn't
    # currently supported in puppet-rspec, so just make sure it compiles
    it { is_expected.to compile }
    it { is_expected.to_not contain_file('/opt/apache-tomcat/foo') }
  end
  context "install from source, unmanaged home" do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        manage_home   => false,
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do default_facts end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
      }
    end
    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
  end
  context "install from source, unmanaged base" do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do default_facts end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_base: false,
      }
    end
    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
  context "install from source, unmanaged home and base" do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        manage_home   => false,
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do default_facts end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_base: false,
      }
    end
    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
  context "install from source, unmanaged catalina.properties" do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do default_facts end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_properties: false,
      }
    end
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/catalina.properties') }
  end
  context "legacy install from source, unmanaged home/base" do
    let :pre_condition do
      'class { "tomcat": }'
    end
    let :facts do default_facts end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        manage_base: false,
      }
    end
    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
end
