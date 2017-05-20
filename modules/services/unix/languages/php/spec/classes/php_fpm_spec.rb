require 'spec_helper'

describe 'php::fpm', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      describe 'when called with no parameters' do
        case facts[:osfamily]
        when 'Debian'
          case facts[:operatingsystem]
          when 'Ubuntu'
            let(:params) { { :package => 'php5.6-fpm', :ensure => 'latest' } }
            it {
              should contain_package('php5.6-fpm').with({
                'ensure' => 'latest',
              })
              should contain_service('php5.6-fpm').with({
                'ensure' => 'running',
              })
            }
          when 'Debian'
            let(:params) { { :package => 'php5-fpm', :ensure => 'latest' } }
            it {
              should contain_package('php5-fpm').with({
                'ensure' => 'latest',
              })
              should contain_service('php5-fpm').with({
                'ensure' => 'running',
              })
            }
          end
        else
          it {
            should contain_service('php-fpm').with({
              'ensure' => 'running',
            })
          }
        end
      end
    end
  end
end
