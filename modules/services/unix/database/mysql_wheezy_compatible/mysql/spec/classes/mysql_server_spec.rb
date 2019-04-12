require 'spec_helper'

describe 'mysql::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) {
        facts.merge({
          :root_home => '/root',
        })
      }

      context 'with defaults' do
        it { is_expected.to contain_class('mysql::server::install') }
        it { is_expected.to contain_class('mysql::server::config') }
        it { is_expected.to contain_class('mysql::server::service') }
        it { is_expected.to contain_class('mysql::server::root_password') }
        it { is_expected.to contain_class('mysql::server::providers') }
      end

      context 'with remove_default_accounts set' do
        let(:params) {{ :remove_default_accounts => true }}
        it { is_expected.to contain_class('mysql::server::account_security') }
      end

      context 'when not managing config file' do
        let(:params) {{ :manage_config_file => false }}
        it { is_expected.to compile.with_all_deps }
      end

      context 'mysql::server::install' do
        it 'contains the package by default' do
          is_expected.to contain_package('mysql-server').with({
            :ensure => :present,
          })
        end
        context 'with package_manage set to true' do
          let(:params) {{ :package_manage => true }}
          it { is_expected.to contain_package('mysql-server') }
        end
        context 'with package_manage set to false' do
          let(:params) {{ :package_manage => false }}
          it { is_expected.not_to contain_package('mysql-server') }
        end
        context 'with datadir overridden' do
          let(:params) {{ :override_options => { 'mysqld' => { 'datadir' => '/tmp' }} }}
          it { is_expected.to contain_mysql_datadir('/tmp') }
        end
      end

      context 'mysql::server::service' do
        context 'with defaults' do
          it { is_expected.to contain_service('mysqld') }
        end
        context 'with package_manage set to true' do
          let(:params) {{ :package_manage => true }}
          it { is_expected.to contain_service('mysqld').that_requires('Package[mysql-server]') }
        end
        context 'with package_manage set to false' do
          let(:params) {{ :package_manage => false }}
          it { is_expected.to contain_service('mysqld') }
          it { is_expected.not_to contain_service('mysqld').that_requires('Package[mysql-server]') }
        end
        context 'service_enabled set to false' do
          let(:params) {{ :service_enabled => false }}

          it do
            is_expected.to contain_service('mysqld').with({
              :ensure => :stopped
            })
          end
          context 'with package_manage set to true' do
            let(:params) {{ :package_manage => true }}
            it { is_expected.to contain_package('mysql-server') }
          end
          context 'with package_manage set to false' do
            let(:params) {{ :package_manage => false }}
            it { is_expected.not_to contain_package('mysql-server') }
          end
          context 'with datadir overridden' do
            let(:params) {{ :override_options => { 'mysqld' => { 'datadir' => '/tmp' }} }}
            it { is_expected.to contain_mysql_datadir('/tmp') }
          end
        end
        context 'with log-error overridden' do
          let(:params) {{ :override_options => { 'mysqld' => { 'log-error' => '/tmp/error.log' }} }}
          it { is_expected.to contain_file('/tmp/error.log') }
        end
      end

      context 'mysql::server::root_password' do
        describe 'when defaults' do
          it {
             is_expected.to contain_exec('remove install pass').with(
               :command => 'mysqladmin -u root --password=$(grep -o \'[^ ]\\+$\' /.mysql_secret) password \'\' && rm -f /.mysql_secret',
               :onlyif  => 'test -f /.mysql_secret',
               :path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
             )
           }
          it { is_expected.not_to contain_mysql_user('root@localhost') }
          it { is_expected.not_to contain_file('/root/.my.cnf') }
        end
        describe 'when root_password set' do
          let(:params) {{:root_password => 'SET' }}
          it { is_expected.to contain_mysql_user('root@localhost') }
          if Puppet.version.to_f >= 3.0
            it { is_expected.to contain_file('/root/.my.cnf').with(:show_diff => false).that_requires('Mysql_user[root@localhost]') }
          else
            it { is_expected.to contain_file('/root/.my.cnf').that_requires('Mysql_user[root@localhost]') }
          end
        end
        describe 'when root_password set, create_root_user set to false' do
          let(:params) {{ :root_password => 'SET', :create_root_user => false }}
          it { is_expected.not_to contain_mysql_user('root@localhost') }
          if Puppet.version.to_f >= 3.0
            it { is_expected.to contain_file('/root/.my.cnf').with(:show_diff => false) }
          else
            it { is_expected.to contain_file('/root/.my.cnf') }
          end
        end
        describe 'when root_password set, create_root_my_cnf set to false' do
          let(:params) {{ :root_password => 'SET', :create_root_my_cnf => false }}
          it { is_expected.to contain_mysql_user('root@localhost') }
          it { is_expected.not_to contain_file('/root/.my.cnf') }
        end
        describe 'when root_password set, create_root_user and create_root_my_cnf set to false' do
          let(:params) {{ :root_password => 'SET', :create_root_user => false, :create_root_my_cnf => false }}
          it { is_expected.not_to contain_mysql_user('root@localhost') }
          it { is_expected.not_to contain_file('/root/.my.cnf') }
        end
        describe 'when install_secret_file set to /root/.mysql_secret' do
          let(:params) {{ :install_secret_file => '/root/.mysql_secret' }}
          it {
            is_expected.to contain_exec('remove install pass').with(
               :command => 'mysqladmin -u root --password=$(grep -o \'[^ ]\\+$\' /root/.mysql_secret) password \'\' && rm -f /root/.mysql_secret',
               :onlyif  => 'test -f /root/.mysql_secret'
            )
          }
        end
      end

      context 'mysql::server::providers' do
        describe 'with users' do
          let(:params) {{:users => {
            'foo@localhost' => {
              'max_connections_per_hour' => '1',
              'max_queries_per_hour'     => '2',
              'max_updates_per_hour'     => '3',
              'max_user_connections'     => '4',
              'password_hash'            => '*F3A2A51A9B0F2BE2468926B4132313728C250DBF'
            },
            'foo2@localhost' => {}
          }}}
          it { is_expected.to contain_mysql_user('foo@localhost').with(
            :max_connections_per_hour => '1',
            :max_queries_per_hour     => '2',
            :max_updates_per_hour     => '3',
            :max_user_connections     => '4',
            :password_hash            => '*F3A2A51A9B0F2BE2468926B4132313728C250DBF'
          )}
          it { is_expected.to contain_mysql_user('foo2@localhost').with(
            :max_connections_per_hour => nil,
            :max_queries_per_hour     => nil,
            :max_updates_per_hour     => nil,
            :max_user_connections     => nil,
            :password_hash            => nil
          )}
        end

        describe 'with grants' do
          let(:params) {{:grants => {
            'foo@localhost/somedb.*' => {
              'user'       => 'foo@localhost',
              'table'      => 'somedb.*',
              'privileges' => ["SELECT", "UPDATE"],
              'options'    => ["GRANT"],
            },
            'foo2@localhost/*.*' => {
              'user'       => 'foo2@localhost',
              'table'      => '*.*',
              'privileges' => ["SELECT"],
            },
          }}}
          it { is_expected.to contain_mysql_grant('foo@localhost/somedb.*').with(
            :user       => 'foo@localhost',
            :table      => 'somedb.*',
            :privileges => ["SELECT", "UPDATE"],
            :options    => ["GRANT"]
          )}
          it { is_expected.to contain_mysql_grant('foo2@localhost/*.*').with(
            :user       => 'foo2@localhost',
            :table      => '*.*',
            :privileges => ["SELECT"],
            :options    => nil
          )}
        end

        describe 'with databases' do
          let(:params) {{:databases => {
            'somedb' => {
              'charset' => 'latin1',
              'collate' => 'latin1',
            },
            'somedb2' => {}
          }}}
          it { is_expected.to contain_mysql_database('somedb').with(
            :charset => 'latin1',
            :collate => 'latin1'
          )}
          it { is_expected.to contain_mysql_database('somedb2')}
        end
      end
    end
  end
end
