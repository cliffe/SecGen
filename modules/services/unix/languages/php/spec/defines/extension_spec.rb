require 'spec_helper'

describe 'php::extension' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let(:pre_condition) { 'include php::params' }

      unless (facts[:osfamily] == 'Suse' || facts[:osfamily] == 'FreeBSD') # FIXME - something is wrong on these
        case facts[:osfamily]
          when 'Debian'
            case facts[:operatingsystem]
              when 'Ubuntu'
                etcdir = '/etc/php/5.6/mods-available'
              else
                etcdir = '/etc/php5/mods-available'
            end
          else
            etcdir = '/etc/php.d'
        end

        context 'installation from repository' do
          let(:title) { 'json' }
          let(:params) {{
            :package_prefix => 'php5-',
            :settings       => {
              'test' => 'foo'
            }
          }}

          it {
            should contain_package('php5-json')
            should contain_php__config('json').with({
              :file   => "#{etcdir}/json.ini",
              :config => {
                'test' => 'foo'
              },
            })
          }
        end

        context 'add settings prefix if requested' do
          let(:title) {'json' }
          let(:params) {{
            :name            => 'json',
            :settings_prefix => true,
            :settings        => {
              'test' => 'foo'
            }
          }}

          it {
            should contain_php__config('json').with({
              :config => {
                'json.test' => 'foo'
              }
            })
          }
        end

        context 'use specific settings prefix if requested' do
          let(:title) {'json' }
          let(:params) {{
            :name            => 'json',
            :settings_prefix => 'bar',
            :settings        => {
              'test' => 'foo'
            }
          }}

          it {
            should contain_php__config('json').with({
              :config => {
                'bar.test' => 'foo'
              }
            })
          }
        end

        context 'non-pecl extensions cannot be configured as zend' do
          let(:title) { 'xdebug' }
          let(:params) {{
            :zend => true,
          }}

          it { expect { should raise_error(Puppet::Error) }}
        end

        context 'pecl extensions can be configured as zend' do
          let(:title) { 'xdebug' }
          let(:params) {{
            :provider => 'pecl',
            :zend     => true
          }}

          it {
            should contain_php__config('xdebug').with({
              :config => {
                'zend_extension' => 'xdebug.so'
              }
            })
          }
        end

        context 'pecl extensions support so_name' do
          let(:title) { 'zendopcache' }
          let(:params) {{
            :provider        => 'pecl',
            :zend            => true,
            :so_name         => 'opcache',
          }}

          it {
            should contain_php__config('zendopcache').with({
              :file   => "#{etcdir}/opcache.ini",
              :config => {
                'zend_extension' => 'opcache.so'
              },
            })
          }
        end

        context 'pecl extensions support php_api_version' do
          let(:title) { 'xdebug' }
          let(:params) {{
            :provider        => 'pecl',
            :zend            => true,
            :php_api_version => '20100525',
          }}

          it {
            should contain_php__config('xdebug').with({
              :config => {
                'zend_extension' => '/usr/lib/php5/20100525/xdebug.so'
              }
            })
          }
        end

        case facts[:osfamily]
        when 'Debian'
          context 'on Debian' do
            let(:title) { 'xdebug' }

            it {
              should contain_php__config('xdebug').with({
                :file => "#{etcdir}/xdebug.ini",
              })
            }
            context 'pecl installation' do
              let(:title) { 'json' }
              let(:params) {{
                  :provider        => 'pecl',
                  :header_packages => ['libmemcached-dev'],
                  :name            => 'nice_name',
                  :settings        => {
                      'test' => 'foo'
                  }
              }}

              it {
                should contain_package('pecl-json')
                should contain_package('libmemcached-dev')
                should contain_package('build-essential')
                should contain_php__config('json').with({
                  :file   => "#{etcdir}/json.ini",
                  :config => {
                    'extension' => 'nice_name.so',
                    'test'      => 'foo'
                  },
                })
              }
            end
          end
        end
      end
    end
  end
end
