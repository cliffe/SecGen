require 'spec_helper'

describe 'python::gunicorn', :type => :define do
  let(:title) { 'test-app' }
  context 'on Debian OS' do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :lsbdistcodename        => 'squeeze',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
      }
    end

    describe 'test-app with default parameter values' do
      context 'configures test app with default parameter values' do
        let(:params) { { :dir => '/srv/testapp' } }
        it { is_expected.to contain_file('/etc/gunicorn.d/test-app').with_mode('0644').with_content(/--log-level=error/) }
      end

      context 'test-app with custom log level' do
        let(:params) { { :dir => '/srv/testapp', :log_level => 'info' } }
        it { is_expected.to contain_file('/etc/gunicorn.d/test-app').with_mode('0644').with_content(/--log-level=info/) }
      end

      context 'test-app with custom gunicorn preload arguments' do
        let(:params) { { :dir => '/srv/testapp', :args  => ['--preload'] } }
        it { is_expected.to contain_file('/etc/gunicorn.d/test-app').with_mode('0644').with_content(/--preload/) }
      end
    end
  end
end
