require 'spec_helper'

describe 'mysql::server::account_security' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        <<-EOF
        anchor {'mysql::server::end': }
      EOF
      end

      context 'with fqdn==myhost.mydomain' do
        let(:facts) do
          facts.merge(root_home: '/root',
                      fqdn: 'myhost.mydomain',
                      hostname: 'myhost')
        end

        ['root@myhost.mydomain',
         'root@127.0.0.1',
         'root@::1',
         '@myhost.mydomain',
         '@localhost',
         '@%'].each do |user|
          it "removes Mysql_User[#{user}]" do # rubocop:disable RSpec/RepeatedExample
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        # When the hostname doesn't match the fqdn we also remove these.
        # We don't need to test the inverse as when they match they are
        # covered by the above list.
        ['root@myhost', '@myhost'].each do |user|
          it "removes Mysql_User[#{user}]" do # rubocop:disable RSpec/RepeatedExample
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        it 'removes Mysql_database[test]' do
          is_expected.to contain_mysql_database('test').with_ensure('absent')
        end
      end

      context 'with fqdn==localhost' do
        let(:facts) do
          facts.merge(root_home: '/root',
                      fqdn: 'localhost',
                      hostname: 'localhost')
        end

        ['root@127.0.0.1',
         'root@::1',
         '@localhost',
         'root@localhost.localdomain',
         '@localhost.localdomain',
         '@%'].each do |user|
          it "removes Mysql_User[#{user}] for fqdn==localhost" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end

      context 'with fqdn==localhost.localdomain' do
        let(:facts) do
          facts.merge(root_home: '/root',
                      fqdn: 'localhost.localdomain',
                      hostname: 'localhost')
        end

        ['root@127.0.0.1',
         'root@::1',
         '@localhost',
         'root@localhost.localdomain',
         '@localhost.localdomain',
         '@%'].each do |user|
          it "removes Mysql_User[#{user}] for fqdn==localhost.localdomain" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end
    end
  end
end
