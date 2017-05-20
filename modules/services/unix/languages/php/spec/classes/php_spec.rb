require 'spec_helper'

describe 'php', :type => :class do
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
            it {
              should contain_class('php::fpm')
              should contain_package('php5.6-cli').with({
                'ensure' => 'present',
              })
              should contain_package('php5.6-fpm').with({
                'ensure' => 'present',
              })
              should contain_class('php::dev')
              should contain_package('php5.6-dev').with({
                'ensure' => 'present',
              })
              # The -xml package is enforced via the dev class
              should contain_package('php5.6-xml').with({
                'ensure' => 'present',
              })
              should contain_package('php-pear').with({
                'ensure' => 'present',
              })
              should contain_class('php::composer')
            }
          when 'Debian'
            it {
              should_not contain_class('php::global')
              should contain_class('php::fpm')
              should contain_package('php5-cli').with({
                'ensure' => 'present',
              })
              should contain_package('php5-fpm').with({
                'ensure' => 'present',
              })
              should contain_package('php5-dev').with({
                'ensure' => 'present',
              })
              should contain_package('php-pear').with({
                'ensure' => 'present',
              })
              should contain_class('php::composer')
            }
          end
        when 'Suse'
          it {
            should contain_class('php::global')
            should contain_package('php5').with({
              'ensure' => 'present',
            })
            should contain_package('php5-devel').with({
              'ensure' => 'present',
            })
            should contain_package('php5-pear').with({
              'ensure' => 'present',
            })
            should_not contain_package('php5-cli')
            should_not contain_package('php5-dev')
            should_not contain_package('php-pear')
          }
        end
      end

      describe 'when called with package_prefix parameter' do
        let(:params) { { :package_prefix => 'myphp-', } }
        case facts[:osfamily]
        when 'Debian'
          case facts[:operatingsystem]
          when 'Ubuntu'
            it {
              should contain_class('php::fpm')
              should contain_package('myphp-cli').with({
                'ensure' => 'present',
              })
              should contain_package('myphp-fpm').with({
                'ensure' => 'present',
              })
              should contain_class('php::dev')
              should contain_package('myphp-dev').with({
                'ensure' => 'present',
              })
              # The -xml package is enforced via the dev class
              should contain_package('myphp-xml').with({
                'ensure' => 'present',
              })
              should contain_package('php-pear').with({
                'ensure' => 'present',
              })
              should contain_class('php::composer')
            }
          when 'Debian'
            it {
              should_not contain_class('php::global')
              should contain_class('php::fpm')
              should contain_package('myphp-cli').with({
                'ensure' => 'present',
              })
              should contain_package('myphp-fpm').with({
                'ensure' => 'present',
              })
              should contain_package('myphp-dev').with({
                'ensure' => 'present',
              })
              should contain_package('php-pear').with({
                'ensure' => 'present',
              })
              should contain_class('php::composer')
            }
          end
        when 'Suse'
          it {
            should contain_class('php::global')
            should contain_package('php5').with({
              'ensure' => 'present',
            })
            should contain_package('myphp-devel').with({
              'ensure' => 'present',
            })
            should contain_package('myphp-pear').with({
              'ensure' => 'present',
            })
            should_not contain_package('myphp-cli')
            should_not contain_package('myphp-dev')
            should_not contain_package('php-pear')
          }
        end
      end

      describe 'when fpm is disabled' do
        let(:params) { { :fpm => false, } }
        it {
          should_not contain_class('php::fpm')
        }
      end
      describe 'when composer is disabled' do
        let(:params) { { :composer => false, } }
        it {
          should_not contain_class('php::composer')
        }
      end
    end
  end
end
