require 'spec_helper'

describe 'php::fpm::pool' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      case facts[:osfamily]
        when 'Debian'
        case facts[:operatingsystem]
        when 'Ubuntu'
          context 'plain config' do
            let(:title) { 'unique-name' }
            let(:params) {{ }}

            it { should contain_file('/etc/php/5.6/fpm/pool.d/unique-name.conf') }
           end
        when 'Debian'
          context 'plain config' do
            let(:title) { 'unique-name' }
            let(:params) {{ }}

            it { should contain_file('/etc/php5/fpm/pool.d/unique-name.conf') }
          end
        end
      end
    end
  end
end
