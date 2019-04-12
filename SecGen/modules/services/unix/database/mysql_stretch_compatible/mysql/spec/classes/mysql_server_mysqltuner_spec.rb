require 'spec_helper'

describe 'mysql::server::mysqltuner' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(staging_http_get: 'curl',
                    root_home: '/root')
      end

      context 'ensure => present' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_staging__file('mysqltuner-v1.3.0').with(source: 'https://github.com/major/MySQLTuner-perl/raw/v1.3.0/mysqltuner.pl')
        }
      end

      context 'ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to compile }
        it { is_expected.to contain_file('/usr/local/bin/mysqltuner').with(ensure: 'absent') }
      end

      context 'custom version' do
        let(:params) { { version: 'v1.2.0' } }

        it { is_expected.to compile }
        it {
          is_expected.to contain_staging__file('mysqltuner-v1.2.0').with(source: 'https://github.com/major/MySQLTuner-perl/raw/v1.2.0/mysqltuner.pl')
        }
      end

      context 'custom source' do
        let(:params) { { source: '/tmp/foo' } }

        it { is_expected.to compile }
        it {
          is_expected.to contain_staging__file('mysqltuner-/tmp/foo').with(source: '/tmp/foo')
        }
      end
    end
  end
end
