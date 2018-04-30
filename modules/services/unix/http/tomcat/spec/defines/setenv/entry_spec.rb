require 'spec_helper'

describe 'tomcat::setenv::entry', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily       => 'Debian',
      :concat_basedir => '/tmp',
      :id             => 'root',
      :path           => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'FOO'
  end
  context 'no quotes' do
    let :params do
      {
        'value' => '/bin/true',
      }
    end

    it { is_expected.to contain_concat('/opt/apache-tomcat/bin/setenv.sh') }
    it { is_expected.to contain_concat__fragment('setenv-FOO').with_content(/export FOO=\/bin\/true/).with({
      'target' => '/opt/apache-tomcat/bin/setenv.sh',
    })
    }
  end
  context 'quotes' do
    let :params do
      {
        'param'      => 'BAR',
        'value'      => '/bin/true',
        'quote_char' => '"',
        'base_path'  => '/opt/apache-tomcat/foo/bin'
      }
    end

    it { is_expected.to contain_concat('/opt/apache-tomcat/foo/bin/setenv.sh') }
    it { is_expected.to contain_concat__fragment('setenv-FOO').with_content(/export BAR="\/bin\/true"/).with({
      'target' => '/opt/apache-tomcat/foo/bin/setenv.sh',
    })
    }
  end
  context 'ensure absent' do
    let :params do
      {
        'value'  => '/bin/true',
      }
    end

    it { is_expected.to contain_concat('/opt/apache-tomcat/bin/setenv.sh') }
    it { is_expected.to contain_concat__fragment('setenv-FOO').with({
      'target' => '/opt/apache-tomcat/bin/setenv.sh',
    })
    }
  end
  context 'specific config_file' do
    let :params do
      {
        'value'       => '/bin/true',
        'config_file' => '/etc/sysconfig/tomcat',
      }
    end

    it { is_expected.to contain_concat('/etc/sysconfig/tomcat') }
    it { is_expected.to contain_concat__fragment('setenv-FOO').with({
      'target' => '/etc/sysconfig/tomcat',
    })
    }
  end
  context 'array' do
    let :params do
      {
        'param'      => 'BAR',
        'value'      => ['/bin/true', '/bin/false'],
        'quote_char' => '"',
        'base_path'  => '/opt/apache-tomcat/foo/bin'
      }
    end

    it { is_expected.to contain_concat('/opt/apache-tomcat/foo/bin/setenv.sh') }
    it { is_expected.to contain_concat__fragment('setenv-FOO').with_content(/export BAR="\/bin\/true \/bin\/false"/).with({
      'target' => '/opt/apache-tomcat/foo/bin/setenv.sh',
    })
    }
  end
  context 'order' do
    let :params do
      {
        'param' => 'BAR',
        'value' => '/bin/true',
        'order' => '10',
      }
    end

    it { is_expected.to contain_concat('/opt/apache-tomcat/bin/setenv.sh') }
    it { is_expected.to contain_concat__fragment('setenv-FOO').with_content(/export BAR=\/bin\/true/).with({
      'target' => '/opt/apache-tomcat/bin/setenv.sh',
      'order'  => '10',
    })
    }
  end
end
