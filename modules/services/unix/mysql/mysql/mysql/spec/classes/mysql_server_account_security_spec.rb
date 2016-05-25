require 'spec_helper'

describe 'mysql::server::account_security' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with fqdn==myhost.mydomain" do
        let(:facts) {
          facts.merge({
            :root_home => '/root',
            :fqdn => 'myhost.mydomain',
            :hostname => 'myhost',
          })
        }

        [ 'root@myhost.mydomain',
          'root@127.0.0.1',
          'root@::1',
          '@myhost.mydomain',
          '@localhost',
          '@%',
        ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        # When the hostname doesn't match the fqdn we also remove these.
        # We don't need to test the inverse as when they match they are
        # covered by the above list.
        [ 'root@myhost', '@myhost' ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        it 'should remove Mysql_database[test]' do
          is_expected.to contain_mysql_database('test').with_ensure('absent')
        end
      end

      context "with fqdn==localhost" do
        let(:facts) {
          facts.merge({
            :root_home => '/root',
            :fqdn => 'localhost',
            :hostname => 'localhost',
          })
        }

        [ 'root@127.0.0.1',
          'root@::1',
          '@localhost',
          'root@localhost.localdomain',
          '@localhost.localdomain',
          '@%',
        ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end

      context "with fqdn==localhost.localdomain" do
        let(:facts) {
          facts.merge({
            :root_home => '/root',
            :fqdn => 'localhost.localdomain',
            :hostname => 'localhost',
          })
        }

        [ 'root@127.0.0.1',
          'root@::1',
          '@localhost',
          'root@localhost.localdomain',
          '@localhost.localdomain',
          '@%',
        ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end
    end
  end
end
